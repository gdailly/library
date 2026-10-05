# CLAUDE.md — Library

Application personnelle de gestion de bibliothèque, partagée avec quelques proches.
Ajout de livres par scan du code-barres ISBN (lot 1), puis reconnaissance de couverture et d'étagère par IA (lots 2 et 3).

Langue : interface et documentation en **français** ; code, noms de classes/variables et commits en **anglais**.

## Stack (imposée)

| Couche | Choix |
| --- | --- |
| Backend | Java 25 (LTS), Spring Boot 4, Gradle (Kotlin DSL, wrapper `gradlew`) |
| Base | MariaDB, migrations Liquibase |
| Frontend | Flutter, cibles **web** et **Android** (iOS plus tard), pas de mode hors-ligne |
| Auth | Google Sign-In → ID token → Spring Security `oauth2-resource-server` |
| IA (lots 2-3) | Claude Haiku 4.5 (`claude-haiku-4-5`) via `com.anthropic:anthropic-java` |
| Déploiement | Docker / docker-compose (serveur perso ou cloud, à décider) |

Package Java racine : `com.gdailly.library`. Code rangé par couche, un package par couche :

| Package | Contenu |
| --- | --- |
| `controller` | Contrôleurs REST et gestion des erreurs HTTP ; n'appellent que `business` |
| `business` | Services métier, transactions ; seuls à utiliser les repositories |
| `repository` | Interfaces Spring Data JPA |
| `entity` | Entités JPA |
| `dto` | Objets d'entrée/sortie de l'API (records) |
| `mapper` | Conversion entité ↔ DTO |
| `exception` | Exceptions métier (400, 403, 404, 409, 503) |
| `security` | Utilisateur courant, filtre d'appartenance, signature HMAC des URL de couvertures |
| `client` | Appels HTTP sortants (Open Library, Google Books, téléchargement des couvertures) |
| `storage` | Fichiers de couvertures sur le volume `covers` (original JPEG, vignettes WebP) |
| `config` | Configuration Spring, propriétés `livre.*` |
| `util` | Utilitaires sans état (ISBN…) |

Les règles de dépendance sont vérifiées par `LayeredArchitectureTest` (ArchUnit).
Migrations : `backend/src/main/resources/db/changelog/` (master YAML + changesets SQL formatés, un fichier par évolution).

## Organisation du dépôt

```
backend/     API Spring Boot (+ tests unitaires et d'intégration dans src/test)
frontend/    App Flutter (+ tests dans test/ et integration_test/)
infra/       docker-compose.yml, .env.example (jamais de .env versionné)
docs/        conception/ (decisions.md fait foi), maquettes/, api/ (openapi.yaml)
tests/       e2e/, plans/ (recette manuelle), data/ (ISBN et photos de test)
scripts/     utilitaires
```

Dépôt Git : GitHub `gdailly/library`. Commit et push uniquement sur demande.

## Authentification et partage

1. Flutter : `google_sign_in` → ID token Google.
2. Chaque appel API : `Authorization: Bearer <id token>`.
3. Backend : validation signature (JWKS Google), `iss` = `accounts.google.com`, `aud` ∈ `GOOGLE_CLIENT_IDS`.
4. L'e-mail doit être membre d'une bibliothèque, sinon 403. Le premier propriétaire vient de `BOOTSTRAP_OWNER_EMAIL`.

Bibliothèque **partagée** : les livres sont communs ; rôles OWNER (invite/retire) et MEMBER. Statut de lecture, note et avis sont **propres à chaque utilisateur**.

## Modèle de données (MariaDB)

| Table | Champs clés |
| --- | --- |
| `app_user` | id, email (unique), name, avatar_url, created_at |
| `library` | id, name |
| `library_member` | library_id, user_id, role (OWNER, MEMBER) |
| `book` | id, library_id, isbn13, title, subtitle, authors (texte), publisher, year, pages, language, cover_key, summary, owned (bool : false = liste d'envies), added_by, created_at |
| `category` | id, library_id, name, color |
| `book_category` | book_id, category_id |
| `reading` | book_id, user_id, status (TO_READ, READING, READ, ABANDONED), rating (1-5, null), review, started_on, finished_on — unique (book_id, user_id) |
| `isbn_lookup` | isbn13 (PK), source (OPEN_LIBRARY, GOOGLE_BOOKS, NOT_FOUND), payload (JSON), cover_key, fetched_at |

## Recherche ISBN (cache obligatoire)

Ordre : livre déjà présent dans la bibliothèque → `isbn_lookup` (valide 180 jours ; 7 jours si NOT_FOUND) → Open Library → Google Books.
Normaliser l'ISBN en 13 chiffres (convertir les ISBN-10). Ne jamais appeler les API externes si le cache est valide.

## Couvertures et vignettes

- Le backend télécharge la couverture une seule fois, la stocke sur le volume `covers` (nom = SHA-256 du contenu → `cover_key`).
- Tailles : `thumb` 160×240 WebP, `medium` 480×720 WebP, `original` ≤ 1200 px JPEG. Génération avec Thumbnailator.
- `GET /api/books/{id}/cover?size=thumb|medium` (Cache-Control long + ETag), `PUT /api/books/{id}/cover` (multipart).
- Flutter web ne peut pas envoyer le Bearer sur une image : l'API renvoie des **URL signées HMAC valides 24 h** (`COVER_URL_SECRET`). Cache côté app avec `cached_network_image`.
- Sans couverture : vignette générée côté app (titre sur fond de couleur).

## API REST (préfixe `/api`, contrat OpenAPI via springdoc → `docs/api/openapi.yaml`)

| Méthode | Chemin | Rôle |
| --- | --- | --- |
| GET | `/me` | Profil + bibliothèques |
| GET | `/books?q=&status=&category=&owned=&minRating=&page=` | Liste filtrée paginée |
| GET / POST / PUT / DELETE | `/books`, `/books/{id}` | CRUD livre |
| PUT | `/books/{id}/reading` | Mon statut / note / avis |
| GET | `/lookup/isbn/{isbn}` | Métadonnées (avec cache) |
| POST | `/lookup/cover`, `/lookup/shelf` | Reconnaissance IA (lots 2-3, 503 si désactivée) |
| CRUD | `/categories` | Catégories |
| GET / POST / DELETE | `/library/members` | Membres (OWNER seulement pour écrire) |

## Reconnaissance IA (lots 2-3, désactivée par défaut)

Interface `BookRecognizer`, implémentation Claude. Config :

```yaml
livre:
  recognition:
    enabled: ${RECOGNITION_ENABLED:false}
    provider: claude
    max-image-size: 5MB
    claude:
      api-key: ${ANTHROPIC_API_KEY:}
      model: ${ANTHROPIC_MODEL:claude-haiku-4-5}
      timeout: 30s
      max-tokens: 1024
```

Redimensionner les photos à ~1000 px avant envoi (coût ≈ 0,002 $ par photo). Toujours une validation humaine du résultat.

## Interface (maquettes validées)

- Couleurs : accent `#1F5E4B` (teinte claire `#E6F0EC`), fond `#FAFAF7`, texte `#1B1E22`, secondaire `#5B6168`, bordures `#E4E4DF`, étoiles `#D99A2B`, erreur `#8A2A1B` sur `#FCEDEA`.
- Polices : Bricolage Grotesque (titres), Instrument Sans (texte) — via `google_fonts`.
- Mobile : barre 3 onglets (Bibliothèque, Envies, Réglages) + bouton flottant « Scanner ». Écrans : Connexion, Bibliothèque (grille/liste, filtres), Scan, Confirmation d'ajout, Fiche livre, Envies, Réglages.
- Web (≥ 1024 px) : menu latéral, grille + fiche en panneau à droite, ajout en fenêtre modale (saisie ISBN d'abord, webcam en option), envies en tableau, réglages en 2 colonnes.
- Cibles tactiles ≥ 44 px ; contraste texte ≥ 4.5:1.
- Bouton de connexion : utiliser le bouton officiel « Sign in with Google ».

## Configuration (infra/.env.example)

`MARIADB_*`, `GOOGLE_CLIENT_IDS`, `BOOTSTRAP_OWNER_EMAIL`, `CORS_ALLOWED_ORIGINS`, `GOOGLE_BOOKS_API_KEY`, `COVER_URL_SECRET`, `RECOGNITION_ENABLED`, `ANTHROPIC_API_KEY`, `ANTHROPIC_MODEL`.
Aucun secret dans le code ni dans les fichiers versionnés.

## Lots

1. **Lot 1 (MVP)** : auth Google, CRUD livres, scan ISBN + cache, statut/note/avis, catégories, liste d'envies, recherche/filtres, couvertures et vignettes, membres.
2. **Lot 2** : reconnaissance par photo de couverture.
3. **Lot 3** : reconnaissance d'étagère, statistiques, export/import CSV.

## Règles de travail

- Avancer par petites étapes qui compilent ; lancer les tests après chaque étape (`./gradlew build` dans `backend/`, `flutter test`).
- Tests d'intégration backend avec Testcontainers (MariaDB).
- Toute nouvelle décision structurante : une ligne datée dans `docs/conception/decisions.md`.
- Ne pas modifier ce fichier ni `decisions.md` sans le signaler.

## Références

- Décisions : `docs/conception/decisions.md`
- Document de conception (en ligne) : https://claude.ai/code/artifact/9b4d471f-628b-4ad6-821f-5cdb1c9c75f7
- Maquettes (en ligne) : https://claude.ai/artifact/KWsTyWyPuFXejV8Tnwga2U
