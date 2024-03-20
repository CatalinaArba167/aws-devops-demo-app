# Version 1
# FROM openjdk:12-alpine

# COPY target/aws-devops-demo-app-*.jar  aws-devops-demo-app.jar

# ENTRYPOINT ["java","-jar","/aws-devops-demo-app.jar"]

# Version2
# FROM maven:3.6.3-adoptopenjdk-11 AS build

# COPY src /home/aws-devops-demo-app/src
# COPY pom.xml /home/aws-devops-demo-app

# WORKDIR /home/aws-devops-demo-app

# RUN mvn -f /home/aws-devops-demo-app/pom.xml clean package


# FROM openjdk:12-alpine
# COPY --from=build /home/aws-devops-demo-app/target/aws-devops-demo-app-*.jar /aws-devops-demo-app.jar
# CMD ["java", "-jar", "/aws-devops-demo-app.jar"]

#Each instruction in the Dockerfile adds a new layer to the image, thus increasing the size of the image.
# The second version (multi-stage build) ensures that the final image contains only what's necessary to run
# the application, reducing the size of the image significantly.

# Version 3

FROM maven:3.6.3-adoptopenjdk-11 AS build

COPY src /home/online-shop/src
COPY pom.xml /home/online-shop

WORKDIR /home/online-shop

RUN mvn -f /home/online-shop/pom.xml clean package

FROM openjdk:12-alpine

# Add the docker-compose-wait tool
#ADD https://github.com/ufoscout/docker-compose-wait/releases/download/2.11.0/wait /wait
#RUN chmod +x /wait


COPY --from=build /home/online-shop/target/online-shop-*.jar /online-shop.jar
#CMD ["/wait", "&&", "java", "-jar", "/online-shop.jar"]
CMD [ "java", "-jar", "/online-shop.jar"]