# Stage 1: Build
FROM eclipse-temurin:17-jdk AS build
WORKDIR /app

# Copy Maven wrapper and pom.xml first
COPY mvnw pom.xml ./
COPY .mvn/ .mvn
RUN chmod +x mvnw

# Pre-download dependencies
RUN ./mvnw dependency:go-offline -B

# Copy source code
COPY src ./src

# Build app
RUN ./mvnw clean package -DskipTests

# Stage 2: Run
FROM eclipse-temurin:17-jdk
WORKDIR /app

# Copy the built jar
COPY --from=build /app/target/*.jar app.jar

# Use Render dynamic port
ENV PORT=8080
EXPOSE $PORT

# Start app
ENTRYPOINT ["sh", "-c", "java -jar app.jar --server.port=$PORT"]
