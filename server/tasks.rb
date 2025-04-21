require 'sinatra'
require 'json'
require 'sqlite3'
require 'jwt'
require 'dotenv'


DBT.results_as_hash=true

Dotenv.load

SECRET_KEY = ENV['SECRET_KEY']

DBT.execute <<-SQL
  CREATE TABLE IF NOT EXISTS tasks (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    task TEXT,
    completed BOOLEAN DEFAULT 0,
    FOREIGN KEY(user_id) REFERENCES users(id)
  );
SQL

puts "inside tasks.rb"
#HELPER-AUTHENTICATOR

helpers do
  def authenticate!
    token= request.cookies["token"]
    puts "token is #{token}"
    halt 401, {error:"unauthorized"}.to_json unless token

    begin
      decoded = JWT.decode(token,SECRET_KEY,true,{algorithm: 'HS256'})
      payload = decoded.first
      retun payload["user_id"]

    rescue => e
       puts e
        halt 401, {error:e}.to_json
    end
    

  end
end



get '/tasks' do
  puts "inside tasks route"
  user_id = authenticate!
  tasks = DBT.execute("SELECT * FROM tasks WHERE user_id = ?",[user_id])
  {tasks: tasks}.to_json
  
end

#ADD TASKS

post '/tasks' do
  user_id = authenticate!
  data = JSON.parse(request.body.read)
  task = data["title"]

  DBT.execute("INSERT INTO tasks VALUES(user_id, task, completed)",[user_id,task,false])
  {
    message:"task added successfully"
}.to_json

end

#MARK TASK AS COMPLETED

put '/tasks/:id' do
  user_id = authenticate!
  task_id = params["id"]

  begin
    DBT.execute("UPDATE tasks SET completed = ? WHERE id = ? AND user_id = ?",[true,task_id,user_id])
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
    DBT.execute("DELETE FROM tasks WHERE id = ? AND user_id = ?",[task_id,user_id])
    {message:"Task deleted successfully"}.to_json

  rescue => e
    halt 401, {error: e}.to_json 
  end
  

end