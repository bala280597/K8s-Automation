# AKS Kubernetes Deployment  in Azure Devops

| Language | BuildType| Author |
| -------- | -------- |--------|
| JAVA |Maven  | BALAMURUGAN BASKARAN|


# Description:
In this project, I am deploying binaries of sample java application in Azure Kubernetes Service in desired cluster.
For Continious Integeration of Docker Build and AKS Deployment, I used Azure Devops.  

# Purpose:
The purpose of the project is to  build the docker file and deploy it in AKS. I created pipeline for the operation. If any commit on respective branch , Pipeline would be triggered. We can also manually trigger the pipeline.

# Agent:
I used Azure agent for the pipeline operation for the time being. The best practice is to use Self Hosted Agents that keep us away from tools installation and reduces running time.

# Pipeline creation:
In the Pipeline , I made option for the two stages. (i.e) we have 2 checkboxes called 'BUILD' and 'DEPLOY'. By this parameters we can select the stages. In some case , If we want to delete or list the pods or other kinds in K8s , we don't need to build a docker image. In that scenario we can select DEPLOY checkbox itself. Only Deploy stage will run.
Some other parameters also mandatory , I would explain in later part of this article while explain about DEPLOY stage.

# BUILD stage.
I created dockerfile. As entire flow needs containerization.
```yaml DOCKERFILE
FROM ubuntu:16.04 as maven
RUN apt-get update -y
RUN apt-get install default-jre -y
RUN apt-get install default-jdk -y
RUN apt-get update -y
ENV JAVA_HOME_8_X64=/usr/lib/jvm/java-8-openjdk-amd64 
RUN apt update -y
RUN apt install maven -y
WORKDIR /app
COPY . .
RUN mvn package
FROM tomcat:8.5.6-jre8-alpine
WORKDIR /app
COPY --from=maven /app/target/helloworld.war /usr/local/tomcat/webapps/helloworld.war
```

In this dockerfile I used two images ubuntu:16.04 with label 'maven' and tomcat image. I installed Java jdk , jre ,maven and set JAVA_HOME environment variable.
Working directory as /app. Build java application with Maven tool and copy the war file into webapp folder of tomcat image.
I used ubuntu image as FROM ubuntu:16.04 as maven . Here maven is image label. So at time of copying war file with new image , Label concept is helpful.

In azure-pipelines.yml, I build the Docker image and push it to docker Hub.
Docker Hub url: https://hub.docker.com/repository/docker/bala2805/k8s_project

# DEPLOY Stage
In the DEPLOY stage, In Azure pipeline , We need mandatory parameters to pass while triggering the pipeline to run this stage.
```YAML
kubernetesServiceEndpoint: Name of Kubernetes service connection that we created with our namespace.
namespace: Name of namespace where we deploy.
command: commands like create, apply, list etc
arguments: Path of deployment file
```
Note : As this approach , We can create every Kind in kubernetes in same yaml file or else need to create seperate task for each kind.
Example: We need to create Deployment and Service Kind means , I would recommend to create single YAML with Service and Deployment kind rather than seperate file for each.

```yaml deploy.yml
apiVersion: v1
kind: Service
metadata:
  name: hello-world
spec:
 type: ClusterIP
 ports:
  - port: 8080
    targetPort: 8080
 selector:
   app: hello-world-app

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-world
spec:
 replicas: 1
 selector:
   matchLabels:
    app: hello-world-app
 template:
   metadata:
    labels:
     app: hello-world-app
   spec:
    containers:
      - name: hello-world
        image: bala2805/k8s_project
        ports:
        - containerPort: 8080
```
In the above Yaml, I had created Kind: Deployment and Service.
With Deployment, I created pods with the image we build in previous stage. Replica denotes number of instances scaled up. Template refer to pod template. with selector, we can choose pods.
With Service, We can actually expose deployment to ip address.Here I used cluster IP. Other options like loadbalencer, nodeport available. Here selector selects deployment that need to be exposed.

