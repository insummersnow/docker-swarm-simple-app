FROM openjdk:8-jdk
COPY ./spring-boot/build/libs /app/spring-boot/build/libs
WORKDIR /app/spring-boot/build/libs
ENTRYPOINT ["java", "-jar", "spring-boot.jar"]