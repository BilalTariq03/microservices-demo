# Stage 1: Build
FROM gradle:8.6-jdk21 AS builder

WORKDIR /app

COPY build.gradle settings.gradle gradlew ./
COPY gradle ./gradle
RUN chmod +x gradlew

RUN ./gradlew downloadRepos --no-daemon

COPY . .
RUN chmod +x gradlew && ./gradlew installDist --no-daemon

# Stage 2: Run
FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

COPY --from=builder /app/build/install/hipstershop ./

EXPOSE 9555

ENTRYPOINT ["/app/bin/AdService"]
