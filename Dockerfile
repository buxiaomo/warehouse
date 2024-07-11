FROM docker.io/openjdk:8-jre
WORKDIR /app
COPY ./target/warehouse-0.0.1-SNAPSHOT.jar /app/main.jar
RUN  mkdir -p /app/tmp
ENTRYPOINT [ "java", "-classpath", ".", "-jar", "-Djava.io.tmpdir=/app/tmp", "-Dspring.config.location=/app/application.yml", "main.jar"]