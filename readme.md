# Tazky - Your tasks companion

    A simple web app used to add and delete tasks. It features a JWT authentication with a token 
being stored in the cookie.

## FEATURES:
    1. Add task
    2. Mark task as completed
    3. Delete task
    4. Sort them in ascending order or in the order in which they are added
    5. User registration and login
    6. Token based authentication using JWT

## TECH STACK:
    Front end : React Js with bootstrap for styling
    Back end : Ruby with sinatra framework

## INSTALLATION
    ### Prerequisites:
        1. ruby
        2. Node.js 
        3. npm
        4. SQLite

    Frontend:
        cd client/
        npm i 
        npm start

    backend:
        cd server/
        bundle i
        ruby app.rb -p 4567


## API ENDPOINTS

    Methods        Endpoints               Usage

    POST            /login                  login 
    POST            /register               register
    GET            /verify              authenticate the user with token
    GET            /tasks               fetch the tasks
    POST            /tasks              Add task to DB
    PUT             /tasks/:id          mark task as completed
    DELETE          /tasks/:id          delete task from DB
    POST            /logout             Expires the token and logs out the user
