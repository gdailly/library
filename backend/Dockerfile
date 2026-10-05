FROM eclipse-temurin:25-jdk AS build
WORKDIR /app
COPY gradle gradle
COPY gradlew settings.gradle.kts build.gradle.kts ./
RUN chmod +x gradlew && ./gradlew --no-daemon -q dependencies > /dev/null
COPY src src
RUN ./gradlew --no-daemon -q bootJar && cp build/libs/library-*-SNAPSHOT.jar app.jar

FROM eclipse-temurin:25-jre
WORKDIR /app
RUN useradd --system --uid 10001 library && mkdir -p /data/covers && chown library /data/covers
COPY --from=build /app/app.jar app.jar
USER library
EXPOSE 8080
# Native access: libwebp is loaded by the webp-imageio plugin.
ENTRYPOINT ["java", "-XX:MaxRAMPercentage=75", "--enable-native-access=ALL-UNNAMED", "-jar", "app.jar"]
