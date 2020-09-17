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

# Pipeline creation.



