# INTRODUCTION TO DOCKER

* Intro to Docker 

**Introductory Video on Docker:**  https://youtu.be/rOTqprHv1YE

```bash
sudo apt-get update # for ubuntu linux
sudo dnf update -y # for amazon linux

sudo dnf install -y docker # if it amazon linux 2023
sudo apt-get install docker # if it is on ubuntu

sudo docker --version   # check version of docker
sudo systemctl status docker # check status of docker
sudo systemctl start docker
sudo systemctl enable docker

sudo usermod -aG docker ec2-user # Add user to the docker group if it is on amazon linux 2023 
sudo usermod -aG docker ubuntu # Add user to the docker group if it is on ubuntu 
newgrp docker # This refreshes permissions so you don't need to logout and login again or use 'sudo' again
```


```bash
- docker pull hello-world // It grabs the image files and stores them in your local "image cache".
	
- docker run hello-world //Downloads + Executes. It pulls the image (if missing), creates a container,  and starts the software inside it from Docker Hub.

- docker pull ubuntu // you can as well pull ubuntu image

- docker images // check images in your local env.

- docker ps // list containers 

- docker ps -a // list all containers running and stopped.

- docker stop CONTAINER_ID
- docker rmi IMAGE_ID
```

However other registries are: GCP Artifact Registry, AWS ECR etc. 
We use the word ‘PULL’ here not download. even though we meant the same thing. But so that when you use the right term people in the industry know you know what you are saying.





#### 2b * Project-Docker Images

So lets say I want to have an html file echo: "I like devOps/cloud engineering
How do I containerise this html file and display it on the browser ?


##### Step 1: Launch an EC2 Instance
OS: Select Amazon Linux 2023 (it comes with AWS CLI pre-installed).
IAM Role: This is the most important part. Instead of managing keys, attach an IAM Role to the EC2 with the AmazonEC2ContainerRegistryFullAccess policy. This allows the EC2 to talk to ECR without you ever typing a password.


##### Step 2: Install Docker:

```bash
sudo yum update -y
sudo yum install -y docker
sudo systemctl start docker
sudo usermod -a -G docker ec2-user
newgrp docker # This refreshes permissions so you don't need 'sudo'
```

* Create the Webpage:
```bash 
mkdir devops-project && cd devops-project
echo '<h1>I like DevOps/Cloud Engineering because I love automating infrastructure and scaling applications globally!</h1>' > index.html
```


* Create the Dockerfile:
```bash
cat <<EOF > Dockerfile
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
EXPOSE 80
EOF
```

At this point you can decide to build image with the name my-index-app: ```docker build -t my-index-app .```

For now container and nginx are not active until you run: ```docker run -d -p 80:80 --name my-running-app my-index-app```

Now the container is active and only inside the container is nginx  active. confirm using: ```docker ps```, ```systemctl status nginx```, then
enter the container with this command: ```docker exec -it <container_id> sh```, then ```ps aux```, you will see nginx running there.

Then you can check this on ec2 browser, remember http runs on port 80 which we exposed in docker: ec2-ip:80, or http://ec2-ip  

But we want to transfer the image to ecr and delete the image from our ec2-instance, so that docker will look for the image
and pull from where we tell it to pull from next time we tell it "run".

* But remember if you havent attached IAM role to allows your running ec2 earlier to AmazonEC2ContainerRegistryFullAccess role that operation wont work. 
    - Go to the AWS Console -> EC2.
    - Select your instance -> Actions -> Security -> Modify IAM Role.
    - Click Create New IAM Role.
    - Create a role for EC2 and attach the policy: AmazonEC2ContainerRegistryFullAccess.
    - Go back to the "Modify IAM Role" screen, select your new role, and click Update.


##### Step 3: Build & Push to ECR

-  Create an ecr repo via this command or on console.
```bash
# aws ecr create-repository --repository-name my-repository --region us-east-1
aws ecr create-repository --repository-name my-repository --region <your-region>
```



- Authenticate (Login):
```bash
# aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 465828358642.dkr.ecr.us-east-1.amazonaws.com
aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <aws_account_id>.dkr.ecr.<region>.amazonaws.com
```


- Build the Image:
```bash 
# we dont need to build the image my-index-app again or rebuild it with docker build -t my-index-app .
# docker build -t my-repository .
docker build -t repository-name .
```

- Tag the image:
```bash
# docker tag my-index-app:latest 465828358642.dkr.ecr.us-east-1.amazonaws.com/my-repository
# docker tag my-repository:latest 465828358642.dkr.ecr.us-east-1.amazonaws.com/my-repository
docker tag REPO_NAME:latest ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/REPO_NAME
```

- Push to ECR:
This "uploads" the image to the AWS cloud.
```bash
# docker push 465828358642.dkr.ecr.us-east-1.amazonaws.com/my-repository
# docker push 465828358642.dkr.ecr.us-east-1.amazonaws.com/my-repository
docker push ACCOUNT_ID.dkr.ecr.REGION.amazonaws.com/REPO_NAME
```


##### Step 4: The "True" DevOps Test (Delete & Pull)
Now we delete the image from the EC2 to prove we can get it back from ECR.
- Delete Local Image:
```bash
docker stop rm container_id &&  docker rm container_id  # stop and remove the container id first before deleting on the ec2 or 
docker rm -f <container_id_or_name> # remove container at once.

# now remove the images on the ec2
docker rmi my-index-app:latest && docker rmi 465828358642.dkr.ecr.us-east-1.amazonaws.com/my-repository:latest
# docker rmi -f 465828358642.dkr.ecr.us-east-1.amazonaws.com/my-repository
# docker rmi -f $(docker images -q) remove all images at once
docker rmi -f ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/REPO_NAME
```


- Pull and Run from ECR:
Watch the terminal—it will say "Pulling from repository" because you deleted the local copy.
```bash

# docker run -d -p 80:80 --name WHATEVER_YOU_WANT 465828358642.dkr.ecr.us-east-1.amazonaws.com/my-repository
# docker run -d -p 80:80 --name pull_from_ecr 465828358642.dkr.ecr.us-east-1.amazonaws.com/my-repository
# docker run -d -p 80:80 my-repository
# docker run -d -p 80:80 465828358642.dkr.ecr.us-east-1.amazonaws.com/my-repository
docker run -d -p 80:80 ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/REPO_NAME
```

##### Step 5: View in Browser
The Security Group:
Go to the AWS EC2 Console, find your instance, click Security, then click the Security Group.
Add Inbound Rule: Type: HTTP | Port: 80 | Source: Anywhere (0.0.0.0/0).
The URL:
Get your Public IPv4 Address from the EC2 dashboard and paste it into your browser:
http://<EC2-PUBLIC-IP>





#### 2c* Mini Project-Docker Containers

```bash
docker start <container_id_or_name>

docker stop <container_id_or_name> # docker stop c2137f6662b2

docker restart <container_id_or_name>

docker rm <container_id_or_name> # docker rm c2137f6662b2

aws ecr list-images --repository-name my-repository

aws ecr batch-delete-image --repository-name my-repository --image-ids imageTag=latest --region us-east-1 # deletes tag

aws ecr batch-delete-image --repository-name my-repository --image-ids imageDigest=sha256:bd0e22d8b3be8ec6a5dbdcdd571c8af45bd2ec04ee43ae617551eea3ff80f30b --region us-east-1   # deletes image itself

aws ecr delete-repository --repository-name my-repository --force --region us-east-1 # deletes ecr repo

aws ecr describe-repositories --region us-east-1 # confirm deletion
```
