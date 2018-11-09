## Learning Kubernetes

This is just a simple demonstration how to get basic understanding how kubernetes works while working step by step.

## Requirements

- You need to have [docker](https://www.docker.com/) installed for your OS
- [minikube](https://github.com/kubernetes/minikube) installed for running locally
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) installed.

## Learning while working.

You first need to create a container image. We will use docker for that. We are creating a simple web server to see how kubernetes works.

- create a file `app.js` and copy this code into it

```js
const http = require('http');
const os = require('os');
console.log("Kubia server starting...");
var handler = function (request, response) {
  console.log("Received request from " + request.connection.remoteAddress);
  response.writeHead(200);
  response.end("You've hit " + os.hostname() + "\n");
};
var www = http.createServer(handler);
www.listen(8080);

```

Now we will create a docker file that will run on cluster when we create a docker image. 

- create a file named `Dockerfile` and copy this code into it.

```docker
FROM node:8

RUN npm i

ADD app.js /app.js

ENTRYPOINT [ "node", "app.js" ]

```

#### Building docker image

Now make sure your **docker server is up and running**. Now we will create a docker image in our local machine. Open your terminal in current project's folder and run

`docker build -t kubia .`

You’re telling Docker to build an image called **kubia** based on the contents of the current directory (note the dot at the end of the build command). Docker will look for the Dockerfile in the directory and build the image based on the instructions in the file.

Now check the your docker image created by running

#### Getting docker images

`docker images`

#### Running the container image

`docker run --name kubia-container -p 8080:8080 -d kubia`

This tells Docker to run a new container called **kubia-container** from the kubia image. The container will be detached from the console (-d flag), which means it will run in the background. Port 8080 on the local machine will be mapped to port 8080 inside the container (-p 8080:8080 option), so you can access the app through [localhost](http://localhost:8080).

#### Accessing your application

Run in your terminal

`curl localhost:8080`
> You’ve hit 44d76963e8e1

#### Lisiting all your running containers

You can list all your running containers by this command.

`docker ps`

The `docker ps` command only shows the most basic information about the containers.

You can see all container by

`docker ps -a`

Also to get additional infomation about a container run this command

`docker inspect kubia-container`

#### Running a shell inside an existing container

The Node.js image on which you’ve based your image contains the bash shell, so you can run the shell inside the container like this:

`docker exec -it kubia-container bash`

