FROM tomcat:perso

ADD target/WebApp.war /usr/local/tomcat/webapps/

EXPOSE 1238


CMD ["catalina.sh", "run"]
