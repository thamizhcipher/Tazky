require 'sinatra'
require 'sinatra/cross_origin'
require 'bcrypt'
# require 'sqlite3'
require 'json'
require 'rack/cors'
require 'rack/session'
require 'jwt'
require 'dotenv/load'
require 'pg'

# Dotenv.load

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

set :bind, '0.0.0.0'

#JWT SECRET KEY
SECRET_KEY = ENV['SECRET_KEY']

#SQlite connection

# DB.results_as_hash = true
# 


 
#PG CONNECTION

# DB=PG.connect(
#   dbname: 'tazky',
#   user: 'root',
#   password: 'root',
#   host: 'localhost'
# )

DB=PG.connect(
  dbname:ENV['DB_NAME'],
  user:ENV['DB_USER'],
  password:ENV['PASSWORD'],
  host:ENV['HOST'],
  port:ENV['PORT'] || 5432
)



#create user table if it doesn't exist

# begin
#     DB.execute <<-SQL
#    CREATE TABLE IF NOT EXISTS users (
#     id INTEGER PRIMARY KEY AUTOINCREMENT,
#     username TEXT ,
#     email TEXT UNIQUE,
#     password_digest TEXT
#  );
#  SQL
# rescue => e
#     puts e
# end

# #create tasks table

# DB.execute <<-SQL
#   CREATE TABLE IF NOT EXISTS tasks (
#     id INTEGER PRIMARY KEY AUTOINCREMENT,
#     user_id INTEGER,
#     task TEXT,
#     completed BOOLEAN DEFAULT 0,
#     FOREIGN KEY(user_id) REFERENCES users(id)
#   );
# SQL


#CREATE USER TABLE IF NOT EXIST IN POSTGRESQL DB

DB.exec <<-PG
  CREATE TABLE IF NOT EXISTS users(
  id SERIAL PRIMARY KEY,
  username TEXT,
  email TEXT UNIQUE,
  password_digest TEXT
  );
PG

#CREATE TASK TABLE IF NOT EXIST IN POSTGRESQL DB

DB.exec <<-PG
  CREATE TABLE IF NOT EXISTS tasks(
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id),
  task TEXT,
  completed BOOLEAN DEFAULT FALSE
  );
PG


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
  
#Email Validation

def validateEmail?(email)
  !!(email =~ /^[^\s@]+@[^\s@]+\.[^\s@]+$/)
end

#Password Validation  

def validatePassword?(password)
    !!(password =~ /^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#$%^&*]).{8,}$/)
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
    email = data['email'].downcase 
    password = data['password']
    password_digest = BCrypt::Password.create(password)

    #Validate password and email
    
    unless validateEmail?(email)
        halt 400, {error: "Invalid email format"}.to_json      
    end
    unless validatePassword?(password)
        halt 400, {error: "Password must be at least 8 characters long and include a number and a special character and one uppercase letter"}.to_json      
    end

    #insert into DB

    begin
      exisiting_user = DB.exec_params("SELECT * FROM users WHERE email = $1",[email])

      if exisiting_user.ntuples > 0
          return  {status:401, message:"user already exists"}.to_json 
        
      end

      DB.exec_params("INSERT INTO users (username,email,password_digest) VALUES ($1, $2, $3)", [user,email,password_digest])
      { status: "success", message: "user registered successfully"}.to_json
    rescue => e
        puts "Error occured #{e}"
        { status: "error", message: e.message }.to_json 
    end
    
end


#Login route


post '/login' do
    data = JSON.parse(request.body.read)
    email = data['email'].downcase
    password = data['password']
    

    begin
        user = DB.exec_params("SELECT * FROM users WHERE email = $1",[email]).first
     
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
                iss: "tasks-manager"
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
    user_id = authenticate!
    op = DB.exec_params("SELECT * FROM tasks WHERE user_id = $1",[user_id])
    tasks= op.map{|row| row} 
      
    {tasks: tasks}.to_json
    
  end
  
  #ADD TASKS
  
  post '/tasks' do
    user_id = authenticate!
    data = JSON.parse(request.body.read)
    task = data["title"]
  
    DB.exec_params("INSERT INTO tasks (user_id, task, completed) VALUES ($1, $2, $3)", [user_id, task, false])

    {
      message:"task added successfully"
  }.to_json
  
  end
  
  #MARK TASK AS COMPLETED
  
  put '/tasks/:id' do
    user_id = authenticate!
    task_id = params["id"]
  
    begin
      DB.exec_params("UPDATE tasks SET completed = $1 WHERE id = $2 AND user_id = $3",[1,task_id,user_id])
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
      DB.exec_params("DELETE FROM tasks WHERE id = $1 AND user_id = $2",[task_id,user_id])
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
  