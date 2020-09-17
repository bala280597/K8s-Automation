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
