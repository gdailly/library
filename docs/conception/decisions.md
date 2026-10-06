# Décisions

Dernière mise à jour : 2026-10-05

| Sujet | Décision |
| --- | --- |
| Backend | Java 25 (LTS) / Spring Boot 4, conteneurisé Docker |
| Base de données | MariaDB, migrations Liquibase |
| Frontend | Flutter, cibles web et Android |
| Hors-ligne | Pas de mode hors-ligne |
| Authentification | Google Sign-In (ID token) validé par Spring Security, liste blanche d'e-mails |
| Partage | Bibliothèque partagée (rôles OWNER / MEMBER) ; statut de lecture et note propres à chaque utilisateur |
| Lot 1 | Scan ISBN, ajout manuel, statut, catégories, note + avis, liste d'envies, recherche, couvertures et vignettes |
| Vignettes | Couverture stockée côté backend (volume `covers`), tailles thumb 160×240 et medium 480×720 en WebP, URL signées 24 h |
| Métadonnées ISBN | Open Library, puis Google Books en secours, avec cache |
| Reconnaissance IA | Lots 2 et 3, Claude Haiku 4.5 (`claude-haiku-4-5`), clé `ANTHROPIC_API_KEY`, désactivée par défaut |
| Dépôt | GitHub `gdailly/library` |
| Versions (2026-10-05) | Spring Boot 4.1.1, Gradle 9.7 (wrapper `gradlew`), image `mariadb:11.8` en local comme en test |
| ISBN unique (2026-10-05) | Un ISBN apparaît au plus une fois par bibliothèque (contrainte en base, 409 sinon) |
| Bibliothèque active (2026-10-05) | Lot 1 : une seule bibliothèque par utilisateur ; s'il en a plusieurs, la première est utilisée |
| Contrat OpenAPI (2026-10-05) | `docs/api/openapi.yaml` est régénéré par le test `OpenApiIT` à chaque `./gradlew build` |
| Build et migrations (2026-10-05) | Gradle (Kotlin DSL) et Liquibase remplacent Maven et Flyway |
| Architecture backend (2026-10-05) | Un package par couche : controller, business, repository, entity, dto, mapper, exception, security, config, util ; règles vérifiées par ArchUnit |
| Suivi de lecture (2026-10-05) | Dates par défaut : début = aujourd'hui pour « En cours », fin = aujourd'hui pour « Lu » (fuseau `Europe/Paris`) ; filtres `status` et `minRating` sur le suivi de l'appelant |
| Recherche ISBN (2026-10-05) | 404 si aucune source ne connaît l'ISBN (mis en cache 7 jours) ; 503 si une source est injoignable, sans mise en cache ; clé `GOOGLE_BOOKS_API_KEY` recommandée (quota anonyme vite épuisé) |
| Couvertures (2026-10-05) | Téléchargées à l'ajout d'un livre issu d'une recherche ISBN (une seule fois, partagées via le cache) ; URL signées `?key=&expires=&sig=` stables sur une période de 24 h, valides 24 à 48 h ; WebP via `com.github.usefulness:webp-imageio` (natif) |
| Couches techniques (2026-10-05) | `client` (HTTP sortant) et `storage` (fichiers) s'ajoutent aux couches ; seule la couche `business` les utilise |
| Mappers (2026-10-06) | MapStruct 1.6.3 : interfaces `@Mapper(config = MappingConfig.class)`, beans Spring injectés par constructeur, tout champ cible non mappé fait échouer le build ; les chaînes passent par `Strings.trimToNull` |
| Outillage qualité (2026-10-06) | Versions dans `backend/gradle/libs.versions.toml` ; mises à jour par Renovate (`renovate.json`, PR groupée le lundi, Java bloqué sur 25 LTS) ; couverture JaCoCo unitaires + intégration |
| Stratégie de test (2026-10-06) | Règles métier testées unitairement (Mockito, agent Java) ; routes protégées vérifiées automatiquement (`EndpointSecurityIT`) ; réponses réelles des API dans `tests/data/isbn` ; tests de mutation PIT hors `check` (`./gradlew pitest`) |
| Frontend (2026-10-06) | Flutter 3.47, Riverpod 3 (sans génération de code, relance automatique désactivée), go_router, organisation par fonctionnalité (`core/`, `features/`, `shared/`) ; widgets Material via le paquet `material_ui` (sorti du SDK) |
| Client API Dart (2026-10-06) | Généré par openapi-generator (`dart-dio`, `json_serializable`) dans `frontend/packages/library_api` via `scripts/generate-api-client.sh` ; champs obligatoires = composants des records Java non annotés `@Nullable` (JSpecify), énumérations partagées |
| Connexion Flutter (2026-10-06) | Bouton officiel Google (GIS) sur le web, `authenticate()` sur Android ; un seul client ID OAuth web (server client ID sur Android) ; polices chargées à l'exécution par `google_fonts` |
