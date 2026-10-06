plugins {
    java
    jacoco
    alias(libs.plugins.spring.boot)
    alias(libs.plugins.spring.dependency.management)
    alias(libs.plugins.pitest)
}

group = "com.gdailly"
version = "0.0.1-SNAPSHOT"
description = "API de gestion de bibliothèque partagée"

java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(25)
    }
}

repositories {
    mavenCentral()
}

// Mockito is attached as a Java agent: dynamic agent loading is deprecated since Java 21.
val mockitoAgent = configurations.create("mockitoAgent")

dependencies {
    mockitoAgent(libs.mockito.core) { isTransitive = false }

    implementation(libs.spring.boot.starter.actuator)
    implementation(libs.spring.boot.starter.data.jpa)
    implementation(libs.spring.boot.starter.liquibase)
    implementation(libs.spring.boot.starter.security)
    implementation(libs.spring.boot.starter.oauth2.resource.server)
    implementation(libs.spring.boot.starter.validation)
    implementation(libs.spring.boot.starter.webmvc)
    implementation(libs.springdoc.webmvc.api)
    implementation(libs.thumbnailator)
    // ImageIO plugin reading and writing WebP (bundles native libwebp for Linux, Windows and macOS).
    implementation(libs.webp.imageio)
    implementation(libs.mapstruct)
    annotationProcessor(libs.mapstruct.processor)
    runtimeOnly(libs.mariadb.client)

    testImplementation(libs.spring.boot.starter.actuator.test)
    testImplementation(libs.spring.boot.starter.data.jpa.test)
    testImplementation(libs.spring.boot.starter.liquibase.test)
    testImplementation(libs.spring.boot.starter.oauth2.resource.server.test)
    testImplementation(libs.spring.boot.starter.security.test)
    testImplementation(libs.spring.boot.starter.validation.test)
    testImplementation(libs.spring.boot.starter.webmvc.test)
    testImplementation(libs.spring.boot.testcontainers)
    testImplementation(libs.testcontainers.junit.jupiter)
    testImplementation(libs.testcontainers.mariadb)
    testImplementation(libs.archunit.junit5)
    testRuntimeOnly(libs.junit.platform.launcher)
}

tasks.withType<JavaCompile> {
    options.encoding = "UTF-8"
    options.compilerArgs.add("-parameters")
}

tasks.named<org.springframework.boot.gradle.tasks.run.BootRun>("bootRun") {
    jvmArgs("--enable-native-access=ALL-UNNAMED")
}

tasks.withType<Test> {
    useJUnitPlatform()
    jvmArgs("--enable-native-access=ALL-UNNAMED")
    jvmArgs("-javaagent:${mockitoAgent.asPath}")
}

// Unit tests (*Test) run with `test`; integration tests (*IT) need Docker and run with `integrationTest`.
tasks.test {
    exclude("**/*IT.class")
}

val integrationTest = tasks.register<Test>("integrationTest") {
    description = "Runs integration tests (*IT) against a MariaDB container."
    group = LifecycleBasePlugin.VERIFICATION_GROUP
    testClassesDirs = sourceSets.test.get().output.classesDirs
    classpath = sourceSets.test.get().runtimeClasspath
    include("**/*IT.class")
    shouldRunAfter(tasks.test)
}

tasks.check {
    dependsOn(integrationTest)
}

// Coverage of unit and integration tests together: build/reports/jacoco/test/html/index.html
jacoco {
    toolVersion = libs.versions.jacoco.get()
}

tasks.jacocoTestReport {
    dependsOn(tasks.test, integrationTest)
    executionData(tasks.test.get(), integrationTest.get())
    reports {
        xml.required = true
        csv.required = true
        html.required = true
    }
}

tasks.check {
    dependsOn(tasks.jacocoTestReport)
}

// Mutation testing of the unit tests (slow, not part of `check`): ./gradlew pitest
// Report: build/reports/pitest/index.html
pitest {
    pitestVersion = libs.versions.pitest.core.get()
    junit5PluginVersion = libs.versions.pitest.junit5.get()
    // Keep the JUnit 6 launcher of Spring Boot instead of the JUnit 5 one the plugin would force.
    addJUnitPlatformLauncher = false
    targetClasses = setOf(
        "com.gdailly.library.business.*",
        "com.gdailly.library.client.*",
        "com.gdailly.library.security.*",
        "com.gdailly.library.storage.*",
        "com.gdailly.library.util.*",
    )
    targetTests = setOf("com.gdailly.library.*Test")
    excludedTestClasses = setOf("*IT", "com.gdailly.library.LayeredArchitectureTest")
    jvmArgs = listOf("--enable-native-access=ALL-UNNAMED", "-javaagent:${mockitoAgent.asPath}")
    threads = 4
    outputFormats = setOf("HTML", "XML")
    timestampedReports = false
}
