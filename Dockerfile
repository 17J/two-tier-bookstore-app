FROM openjdk:11-slim
WORKDIR /app
RUN apt-get update && apt-get install -y maven
COPY . .
RUN mvn clean package -DskipTests=true
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "target/bookStore-0.0.1-SNAPSHOT.jar"]