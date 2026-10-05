# Backend — API Spring Boot

Java 25, Spring Boot 4.1, Gradle 9.7 (Kotlin DSL, wrapper `gradlew`), MariaDB (Liquibase).

## Commandes

Prérequis : JDK 25 (`JAVA_HOME`) et Docker démarré (Testcontainers pour les tests d'intégration).

```bash
./gradlew test               # tests unitaires (*Test), sans Docker
./gradlew integrationTest    # tests d'intégration (*IT), MariaDB en conteneur
./gradlew build              # tout : compilation, tests unitaires et d'intégration, jar
./gradlew bootTestRun        # lance l'API avec une MariaDB jetable (TestLibraryApplication)
```

`./gradlew integrationTest` régénère aussi `docs/api/openapi.yaml`.

Avec la stack complète : `docker compose --env-file .env up -d --build` depuis `infra/`.

## Structure (un package par couche)

```
src/main/java/com/gdailly/library/
├── controller/   contrôleurs REST, gestion des erreurs HTTP (ProblemDetail)
├── business/     services métier et transactions, création du 1er propriétaire
├── repository/   interfaces Spring Data JPA
├── entity/       entités JPA
├── dto/          records d'entrée/sortie de l'API, pagination
├── mapper/       conversion entité ↔ DTO
├── exception/    exceptions métier (400, 403, 404, 409, 503)
├── security/     membre courant (CurrentUser), filtre 403 pour les comptes non invités, URL signées des couvertures
├── client/       HTTP sortant : Open Library, Google Books, téléchargement des couvertures
├── storage/      fichiers de couvertures (original JPEG ≤ 1200 px, medium et thumb WebP)
├── config/       propriétés `livre.*`, sécurité (validation ID token Google), OpenAPI
└── util/         normalisation ISBN-10 → ISBN-13
src/main/resources/db/changelog/   changelog Liquibase (master YAML + changesets SQL)
```

Dépendances autorisées : controller → business → repository → entity. `client` et `storage` ne sont utilisés que par `business`. Le test `LayeredArchitectureTest` (ArchUnit) fait échouer le build en cas d'écart.
