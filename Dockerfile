FROM tomcat:8.5.6-jre8-alpine
MAINTAINER gsk
COPY drop/target/helloworld.war /usr/local/tomcat/webapps/helloworld.war