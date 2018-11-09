## Learning Kubernetes

This is just a simple demonstration to get basic understanding how kubernetes works while working step by step.

## Requirements

- You need to have [docker](https://www.docker.com/) installed for your OS
- [minikube](https://github.com/kubernetes/minikube) installed for running locally
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) installed.

## Simple conepts before we start

#### What is docker

Docker is platform for packaging, distribution and running applications. It allows you to package your application together with its whole environment. This can be either a few libraries that the app requires or even all the files that are usually available on the filesystem of an installed operating system. Docker makes it possible to transfer this package to a central repository from which it can then be transferred to any computer running Docker and executed there

Three main concepts in Docker comprise this scenario:
- **Images** :— A Docker based container image is something you package your application and its environment into. It contains the filesystem that will be available to the application and other metadata, such as the path to the executable that should be executed when the image is run.
- **Registries** :- A Docker Registry is a repository that stores your Docker images and facilitates easy sharing of those images between different people and computers. When you build your image, you can either run it on the computer you’ve built it on, or you can push (upload) the image to a registry and then pull (download) it on another computer and run it there. Certain registries are pub- lic, allowing anyone to pull images from it, while others are private, only accessi- ble to certain people or machines.
- **Containers** :- A Docker-based container is a regular Linux container created from a Docker-based container image. A running container is a process running on the host running Docker, but it’s completely isolated from both the host and all other processes running on it. The process is also resource-constrained, meaning it can only access and use the amount of resources (CPU, RAM, and so on) that are allocated to it.

## Learning while working

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

This command lists all the images.

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

Also to get additional infomation about a container run this command

`docker inspect kubia-container`

You can see all container by

`docker ps -a`

#### Running a shell inside an existing container

The Node.js image on which you’ve based your image contains the bash shell, so you can run the shell inside the container like this:

`docker exec -it kubia-container bash`

This will run bash inside the existing **kubia-container** container. The **bash** process will have the same Linux namespaces as the main container process. This allows you to explore the container from within and see how Node.js and your app see the system when running inside the container. The **-it** option is shorthand for two options:

- -i, which makes sure STDIN is kept open. You need this for entering commands into the shell.
- -t, which allocates a pseudo terminal (TTY).

#### Exploring container from within

Let’s see how to use the shell in the following listing to see the processes running in the container.

```bash
root@c61b9b509f9a:/# ps aux
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.4  1.3 872872 27832 ?        Ssl  06:01   0:00 node app.js
root        11  0.1  0.1  20244  3016 pts/0    Ss   06:02   0:00 bash
root        16  0.0  0.0  17504  2036 pts/0    R+   06:02   0:00 ps aux
```

You see only three processes. You don’t see any other processes from the host OS.


Like having an isolated process tree, each container also has an isolated filesystem. Listing the contents of the root directory inside the container will only show the files in the container and will include all the files that are in the image plus any files that are created while the container is running (log files and similar), as shown in the fol- lowing listing.

```bash
root@c61b9b509f9a:/# ls
app.js  bin  boot  dev  etc  home  lib  lib64  media  mnt  opt  package-lock.json  proc  root  run  sbin  srv  sys  tmp  usr  var
```

It contains the **app.js** file and other system directories that are part of the node:8 base image you’re using. To exit the container, you exit the shell by running the **exit** command and you’ll be returned to your host machine (like logging out of an ssh session, for example).

#### Stopping and removing a container

`docker stop kubia-container`

This will stop the main process running in the container and consequently stop the container, because no other processes are running inside the container. The container itself still exists and you can see it with **docker ps -a**. The -a option prints out all the containers, those running and those that have been stopped. To truly remove a container, you need to remove it with the **docker rm** command:

`docker rm kubia-container`

This deletes the container. All its contents are removed and it can’t be started again.

#### Pushing the image to an image registry

The image you’ve built has so far only been available on your local machine. To allow you to run it on any other machine, you need to push the image to an external image registry. For the sake of simplicity, you won’t set up a private image registry and will instead push the image to[Docker Hub](http://hub.docker.com)

Before you do that, you need to re-tag your image according to Docker Hub’s rules. Docker Hub will allow you to push an image if the image’s repository name starts with your Docker Hub ID. You create your Docker Hub ID by registering at [hub-docker](http://hub.docker.com). I’ll use my own ID (knrt10) in the following examples. Please change every occurrence with your own ID.

Once you know your ID, you’re ready to rename your image, currently tagged as kubia, to knrt10/kubia (replace knrt10 with your own Docker Hub ID):

`docker tag kubia knrt10/kubia`

This doesn’t rename the tag; it creates an additional tag for the same image. You can confirm this by listing the images stored on your system with the docker images command, as shown in the following listing.

`docker images | head`

As you can see, both kubia and knrt10/kubia point to the same image ID, so they’re in fact one single image with two tags.

#### Pushing image to docker hub

Before you can push the image to Docker Hub, you need to log in under your user ID with the **docker login** command. Once you’re logged in, you can finally push the yourid/kubia image to Docker Hub like this:

`docker push knrt10/kubia`
