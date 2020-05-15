FROM tomcat:8.0-alpine

ADD target/WebApp.war /usr/local/tomcat/webapps/

EXPOSE 1238


CMD ["catalina.sh", "run"]
