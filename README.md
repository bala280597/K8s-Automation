| Language | BuildType| Author |
| -------- | -------- |--------|
| JAVA |Maven  | Microsoft|


# Hello World application

Sample Hello world web application consuming Pipleline framwork.


### Pipleline framwork Usage
The Java-CI template is injected into `azure-pipelines.yml` as below.

```yaml
resources:
  repositories:
    - repository: templates
      type: git
      name: RD Tech Strategy Design and Test/Pipeline-Framework
      ref: refs/heads/master
 

stages:
- template: pipelineascode/templates/java/java-ci.yml@templates
  parameters:
    AGENT: 'windows'
    DOCKER_PUBLISH: true
    BUILD: 'maven'
    UNIT_TEST: 'mavenTest'
    CODE_ANALYSIS: 'sonar'
    SONAR_TOKEN: $(SONAR_LOGIN)
    DESTINATION_FEED: '250298fa-ba3e-4e8f-805a-f50a1edb87d3/936a4e66-7af6-42f2-9fd6-59b4f1dd9ba0'
    DOCKER_REGISTRY: $(DOCKER_REGISTRY)
    DOCKER_REGISTRY_USER: $(DOCKER_REGISTRY_USER)
    DOCKER_REGISTRY_PASSWORD: $(DOCKER_REGISTRY_PASSWORD)
    REPOSITORY: helloworld-app
   
```

### CI Parameters
- `BUILD`: Specified as `maven` because the build type of this application is `Maven`.
- `UNIT_TEST`: Specified as `mavenTest` because the build type of this application is `Maven`.
- `CODE_ANALYSIS`:Specified `sonar` because currently code analysis tool `Sonar` is used.
- `PUBLISH`: Specified as `true` beacaue we need to publish build artifacts to `Azure artifacts`
- `DOCKER_PUBLISH`: Specified as `True` beacuse this project shouble be containerized and published to specified directory
- `AGENT`: Specified as `linux` beacuse job is running on `linux` agent

### Sonar Parameters
- `SONAR_URL`: The URL of the sonarqube is specified here.
- `SONAR_TOKEN`: The Autentication of the sonarqube specified here.

### Docker Parameters
- `DOCKER_REGISTRY`: The Login server of the docker registry is specified here
- `DOCKER_REGISTRY_USER`: The username of the docker registry is specified here. 
- `DOCKER_REGISTRY_PASSWORD`: The Autentication of the docker registry is specified  here.
- `REPOSITORY`: The repository name of the docker registry were the docker image should be pushed must is specified here.

### Azure Artifacts Publish Parameters
- `DESTINATION_FEED`: Name or ID of the Artifacts feed to publish is specified here. 

### Maven Parameters
`Note:` Maven parameters are not used here because there is need for any custom parameter,so we are using the default parameter which is specified,please refer to [maven](https://dev.azure.com/DevOps-RD/RD%20Tech%20Strategy%20Design%20and%20Test/_git/Pipeline-Framework?path=%2Fpipelineascode%2FDocumentation%2FJava%2FMavenBuild.md&_a=preview) documentaion.
 