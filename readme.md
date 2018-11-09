## Learning Kubernetes

This is just a simple demonstration to get basic understanding how kubernetes works while working step by step.

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
