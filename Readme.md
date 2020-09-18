# Cloud AKS Kubernetes Deployment in Azure Devops

| Deployment | Type| Author |
| -------- | -------- |--------|
| Azure Kubernetes Service |Cloud  | BALAMURUGAN BASKARAN|


# Description:
In this project, I am deploying binaries of sample java application in Azure Kubernetes Service in desired cluster using docker image.
For Continious Integeration of Docker Build and AKS Deployment, I used Azure Devops. I developed automation script in `azure-pipelines.yml` .

# Purpose:
The purpose of the project is to  build the docker file and deploy it in AKS. I created pipeline for the operation. If any commit on respective branch , Pipeline would be triggered. We can also manually trigger the pipeline.

# Agent:
I used Azure agent for the pipeline operation for the time being. The best practice is to use Self Hosted Agents that keep us away from tools installation and reduces running time.

```YAML
pool:
    vmImage: 'ubuntu-latest'
```
# Screenshot
I attached Screenshots to Screenshot folders at root directory.

# Pipeline creation:
In the Pipeline , we have 2 boolean parameters called 'BUILD' and 'DEPLOY'. By this parameters we can select the BUILD and  DEPLOY stages. In some case , If we want to delete or list the pods or other kinds in K8s , we don't need to build a docker image. In that scenario we can select DEPLOY checkbox itself. Only Deploy stage will run.
Some other parameters also mandatory , I would explain in later part of this article while explain about DEPLOY stage.
```yaml DOCKERFILE
trigger:
- master

parameters:
- name: BUILD
  type: boolean
  default: true
- name: DEPLOY
  type: boolean
  default: true
- name: serviceConnection
  default: '' 
- name: nameSpace
  default: '' 
- name: commands
  default: '' 
- name: arguments
  default: '' 
resources:
- repo: self
variables:
  tag: '$(Build.BuildId)'
stages:
- stage: Build
  displayName: Build image
  jobs:  
  - ${{ if eq(parameters.BUILD, true) }}:
    - job: Build
      displayName: Build
      pool:
        vmImage: 'ubuntu-latest'
      steps:
      - task: Docker@2
        inputs:
          containerRegistry: 'Docker'
          repository: 'bala2805/k8s_project'
          command: 'buildAndPush'
          Dockerfile: '**/Dockerfile'
          tags: |
            $(tag)  
  - ${{ if eq(parameters.DEPLOY, true) }}:          
    - job: DEPLOY
      displayName: DEPLOY
      pool:
        vmImage: 'ubuntu-latest'
      steps: 
      - task: Kubernetes@1
        displayName: kubectl apply using arguments
        inputs:
          connectionType: Kubernetes Service Connection
          kubernetesServiceEndpoint: ${{ parameters.serviceConnection }}
          namespace: ${{ parameters.nameSpace }}
          command: ${{ parameters.commands }}
          arguments: -f  ${{ parameters.arguments }}
```

# BUILD stage:
I created `Dockerfile`. As entire flow needs containerization.
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

In this dockerfile I used two images `ubuntu:16.04 `with label `maven` and `tomcat` image. I installed Java jdk , jre ,maven and set JAVA_HOME environment variable.
Working directory as /app. Build java application with Maven tool and copy the war file into webapp folder of tomcat image.
I used ubuntu image as FROM ubuntu:16.04 as maven . Here `maven is image label`. So at time of copying war file with new image , Label concept is helpful.

In azure-pipelines.yml, I build the Docker image and push it to docker Hub.
Docker Hub url: `https://hub.docker.com/repository/docker/bala2805/k8s_project`

# DEPLOY Stage:
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
    targetPort: ${TARGETPORT}
 selector:
   app: hello-world-app

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-world
spec:
 replicas: ${REPLICAS}
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
        image: ${IMAGE}
        ports:
        - containerPort: ${CONTAINERPORT}
```
In the above Yaml, I had created Kind: Deployment and Service in single `deploy.yml` file.
With Deployment, I created pods with the image we build in previous stage. Replica refers number of instances scaled up. Template refer to pod template which mean while creating deployment , pods are also created. with selector, we can choose pods for the deployment.
With Service, We can actually expose deployment to ip address.Here I used cluster IP. Other options like loadbalencer, nodeport available. Here selector selects deployment that need to be exposed.

# Parameters for values.yml
The user can add following details in `values.yml` file for the deploy.yml.
```YAML
variables:
  REPLICAS: 1
  TARGETPORT: 8080
  IMAGE: bala2805/k8s_project
  CONTAINERPORT: 8080
  tag: '$(Build.BuildId)'
```
These variables are substituted in `deploy.yml`. So With these we can use our deployment file as template and passing variables dynamically.


# Thank You
