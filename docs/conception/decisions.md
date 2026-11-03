# Décisions

Dernière mise à jour : 2026-10-13

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
| Déploiement (2026-10-13) | `infra/docker-compose.prod.yml` : Caddy sert l'app web et transmet `/api` au backend (même origine, pas de CORS) ; HTTPS Let's Encrypt automatique si `SITE_ADDRESS` est un domaine (DuckDNS par défaut), HTTP sur l'IP sinon ; HTTP non chiffré autorisé sur Android seulement si `API_BASE_URL` commence par `http://` |
| Sources ISBN multiples (2026-11-01) | Open Library, Google Books et le catalogue de la BnF (API SRU, UNIMARC, sans clé ; recherche par ISBN-13 et ISBN-10) sont interrogés en parallèle ; fusion champ par champ : titre, sous-titre, auteurs, éditeur, année BnF → Open Library → Google ; pages Open Library → BnF → Google ; langue et résumé Google → BnF ; couverture Google puis Open Library (essayées dans l'ordre). `isbn_lookup.payload` garde la réponse brute de chaque source (`{"sources": {...}}`), `source` celle du titre |
| Administration des métadonnées (2026-11-01) | Page réservée aux propriétaires (`/api/admin/metadata`) : resynchronisation de toute la bibliothèque en tâche de fond (complète seulement les champs vides et la couverture manquante, pause de 500 ms entre deux livres), resynchronisation d'un livre depuis sa fiche (compléter ou tout remplacer, une valeur inconnue des sources n'efface jamais celle du livre), purge du cache ISBN (introuvables ou tout) ; une resynchronisation réutilise les réponses de moins d'un jour |
| Proxy et même origine (2026-11-01) | Le backend lit `X-Forwarded-Proto/Host` (`server.forward-headers-strategy: framework`) et le Caddy de l'app fait confiance aux en-têtes des proxys privés (`trusted_proxies private_ranges`) : derrière un Caddy partagé qui termine HTTPS, les requêtes de l'app web ne sont plus rejetées en 403 « Invalid CORS request » |
| Administrateur et comparaison des sources (2026-11-01) | L'administration des métadonnées est réservée au compte `BOOTSTRAP_OWNER_EMAIL` (et non plus aux propriétaires), le cache ISBN étant commun à l'application. Page de comparaison livre par livre (lecture du cache, sans appel aux API) : valeur du livre, fusion et réponse de chaque source ; un champ ou toute une source peut être repris dans le livre ; chaque source peut être réinterrogée seule. Mode `FETCH` : met à jour les réponses des sources sans modifier les livres |
| Séries (2026-11-02) | `book.series` et `book.series_number` (tome, entier) : série et tome de la BnF (zone 225, sinon 461), sinon la série seule d'Open Library (sujet `series:`) ; Google Books n'est pas utilisé. Les orthographes d'une même série sont regroupées (casse, accents, espaces). Les tomes manquants vont de 1 au plus grand tome connu de la bibliothèque (au plus 500) : les tomes parus ensuite ne sont pas connus. Onglet « Séries » entre Bibliothèque et Envies |
| Connexion conservée au rechargement (2026-11-02) | Sur le web, le jeton d'identité Google accepté par `/api/me` est gardé dans le `localStorage` du navigateur et réutilisé au rechargement tant qu'il est valide (environ 1 h après la connexion, marge de 2 min) ; oublié à la déconnexion ou si l'API le refuse. Pas de session propre à l'application (choix de Guillaume) : il faut toujours se reconnecter environ une heure après la connexion |
| Tomes des séries depuis la BnF (2026-11-03) | Une tâche planifiée (`@Scheduled`, 2 min après le démarrage puis toutes les heures, 20 séries par passage, 1 s entre deux appels) liste tous les tomes de chaque série : notice de série BnF lue dans la zone 461 $0 de la réponse BnF en cache d'un tome, puis index SRU `bib.ens2bib` (sinon `bib.col2bib`), un tirage par numéro (avec ISBN, puis le plus récent). Résultat partagé par toutes les bibliothèques (`series_catalog`, `series_volume`), relu après 30 jours (7 si rien trouvé). Les tomes listés comptent comme manquants ; dans l'app, les tomes non possédés sont grisés avec une étiquette (Possédé, Envie, Manquant) et une couverture Open Library par ISBN quand elle existe. `livre.series.refresh-enabled=false` coupe la tâche |
