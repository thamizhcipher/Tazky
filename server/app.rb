require 'sinatra'
require 'sinatra/cross_origin'
require 'bcrypt'
require 'sqlite3'
require 'json'
require 'rack/cors'
require 'rack/session'
require 'jwt'
require 'dotenv'

Dotenv.load

use Rack::Cors do
    allow do
            origins 'http://localhost:3000'
            resource '*', 
            headers: :any, 
            methods: [:get,:post,:options,:put,:delete], 
            credentials: true  
    end  
end

configure do
    enable :cross_origin
    set :allow_origin, 'http://localhost:3000'
    set :allow_methods, [:get, :post, :options, :put, :delete]
    set :allow_credentials, true
    set :allow_headers, ['*']
end

before do
    response.headers['Access-Control-Allow-Origin'] = 'http://localhost:3000'
    response.headers['Access-Control-Allow-Credentials'] = 'true'
    content_type :json
end

#JWT SECRET KEY
SECRET_KEY = ENV['SECRET_KEY']

#SQlite connection

DB = SQLite3::Database.new File.expand_path('users.db', __dir__)
DB.results_as_hash = true

#create user table if it doesn't exist

begin
    DB.execute <<-SQL
   CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT ,
    email TEXT UNIQUE,
    password_digest TEXT
 );
 SQL
rescue => e
    puts e
end

#create tasks table

DB.execute <<-SQL
  CREATE TABLE IF NOT EXISTS tasks (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    task TEXT,
    completed BOOLEAN DEFAULT 0,
    FOREIGN KEY(user_id) REFERENCES users(id)
  );
SQL


#HELPER-AUTHENTICATOR

helpers do
    def authenticate!
      token= request.cookies["token"]
      halt 401, {error:"unauthorized"}.to_json unless token
  
      begin
        decoded = JWT.decode(token,SECRET_KEY,true,{algorithm: 'HS256'})
        payload = decoded.first
        return payload["user_id"]
  
      rescue => e
         puts e
          halt 401, {error:e}.to_json
      end
      
  
    end
  end
  


#ROUTES SECTION


#AUTH_VERIFICATION_ROUTE

get '/verify' do
    
    authenticate!
    {status:200, message:"user authenticated"}.to_json
end

#Register route

post '/register' do
    # puts "inside register route"
    data = JSON.parse(request.body.read)
    user = data['name']
    # puts user
    email = data['email']
    password = data['password']
    password_digest = BCrypt::Password.create(password)

    #insert into DB

    begin
      exisiting_user = DB.execute("SELECT * FROM users WHERE email = ?",[email]).first

      if exisiting_user
          return  {status:401, message:"user already exists"}.to_json 
        
      end

      DB.execute("INSERT INTO users (username,email,password_digest) VALUES (?, ?, ?)", [user,email,password_digest])
      { status: "success", message: "user registered successfully"}.to_json
    rescue => e
        puts "Error occured #{e}"
        { status: "error", message: e.message }.to_json 
    end
    
end


#Login route


post '/login' do
    data = JSON.parse(request.body.read)
    email = data['email']
    password = data['password']
    

    begin
        puts "Using DB at: #{File.expand_path('users.db', __dir__)}"
        user = DB.execute("SELECT * FROM users WHERE email = ?",[email]).first
     
    rescue => e
        puts "error in login #{e}" 
    end
    
   

    if user && BCrypt::Password.new(user['password_digest']) == password
            #Set expiry time
            exp = Time.now.to_i + 20 * 60
            payload ={
                user_id: user['id'],
                expiry:exp,
                iat:Time.now.to_i,
                iss: "taks-manager"
            }

            token = JWT.encode(payload,SECRET_KEY,'HS256')
            response.set_cookie(
                "token",
                value:token,
                path:"/",
                domain: "localhost",
                httponly:true,
                same_site: :None,
                secure: true
            )
            
            { status: 200, message: "Login Successful"}.to_json
    else
        { status: 401, message: "Invalid login credentials"}.to_json
    end
end



get '/' do
     "hello everyone"  
end


get '/tasks' do
    puts "inside tasks route"
    user_id = authenticate!
    tasks = DB.execute("SELECT * FROM tasks WHERE user_id = ?",[user_id])
    {tasks: tasks}.to_json
    
  end
  
  #ADD TASKS
  
  post '/tasks' do
    user_id = authenticate!
    data = JSON.parse(request.body.read)
    task = data["title"]
  
    DB.execute("INSERT INTO tasks (user_id, task, completed) VALUES (?, ?, ?)", [user_id, task, 0])

    {
      message:"task added successfully"
  }.to_json
  
  end
  
  #MARK TASK AS COMPLETED
  
  put '/tasks/:id' do
    user_id = authenticate!
    task_id = params["id"]
  
    begin
      DB.execute("UPDATE tasks SET completed = ? WHERE id = ? AND user_id = ?",[1,task_id,user_id])
      {message:"task added successfully"}.to_json
  
    rescue => e
      halt 401 , {error: e}.to_json 
  
    end
    
  end
  
  #DELETE A TASK
  
  delete '/tasks/:id' do
    user_id = authenticate!
    task_id = params["id"]
  
    begin
      DB.execute("DELETE FROM tasks WHERE id = ? AND user_id = ?",[task_id,user_id])
      {message:"Task deleted successfully"}.to_json
  
    rescue => e
      halt 401, {error: e}.to_json 
    end
    
  
  end

#LOGOUT ROUTE

post '/logout' do
    
    response.set_cookie(
      "token",
      value:"",
      path:"/",
      domain: "localhost",
      httponly:true,
      same_site: :None,
      secure: true,
      expires: Time.at(0)
  )
end



options '*' do
    response.headers['Access-Control-Allow-Origin'] = 'http://localhost:3000'
    response.headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS'
    response.headers['Access-Control-Allow-Headers'] = 'Content-Type'
    response.headers['Access-Control-Allow-Credentials'] = 'true'
    200
  end
  