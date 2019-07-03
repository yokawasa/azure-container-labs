#FROM openjdk:8
FROM mcr.microsoft.com/java/jdk:8u212-zulu-alpine
VOLUME /tmp
ADD target/*.jar /app.jar
ENTRYPOINT [ "java", "-jar", "/app.jar", "--server.port=80" ]
