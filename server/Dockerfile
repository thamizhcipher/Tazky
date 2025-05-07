#Base image
FROM ruby:3.2-slim

#set working dir
WORKDIR /task_manager/server/

#copy gem file
COPY Gemfile* ./

#copy rest of code
COPY . .

# Install dependencies for Ruby app (PostgreSQL, build tools, etc.)
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs

#install gems
RUN  bundle install

#expose port
EXPOSE 4567

#run the server
CMD [ "ruby","app.rb","-p","4567" ]