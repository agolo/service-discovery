FROM agolo.azurecr.io/ops/maven17 as mvn
COPY . /service-discovery
WORKDIR /service-discovery
RUN ./gradlew bootJar

FROM openjdk:17-jdk-alpine
EXPOSE 8080
EXPOSE 8081

RUN adduser -D agolo
USER agolo
COPY --from=mvn /service-discovery/build/libs/service-discovery*.jar app.jar
ENV JAVA_OPTS="-XX:MaxRAMPercentage=75"
HEALTHCHECK --interval=5s --timeout=5s --retries=10 --start-period=5s \
  CMD curl -f http://localhost:8080/health || exit 1
ENTRYPOINT exec java $JAVA_OPTS -Djava.security.egd=file:/dev/./urandom -jar /app.jar