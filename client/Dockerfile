#1. Base image

FROM node:18 AS builder

#2. Wokring dir

WORKDIR /task_manager/client/

#3. dependency files

COPY package*.json ./

#4. copy code files

COPY . .

#5. install dependencies

RUN npm install

RUN npm run build

#stage 2:
#use ngnix

FROM nginx:alpine
COPY --from=builder /task_manager/client/build /usr/share/nginx/html

#update default ngnix
COPY nginx.conf /etc/nginx/conf.d/default.conf

#expose port

EXPOSE 3000

#start development server

CMD [ "nginx", "-g", "daemon off;" ]