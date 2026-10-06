# Frontend — application Flutter

Flutter 3.47 (Dart 3.13), cibles web et Android. État : Riverpod 3 ; navigation : go_router ; widgets Material : paquet `material_ui`.

## Commandes

Prérequis : SDK Flutter (`flutter` dans le PATH), backend démarré (voir `backend/README.md`).

En local, le plus simple : renseigner `.env.local` à la racine, puis `./scripts/dev-backend.sh` et `./scripts/dev-web.sh`.

```bash
flutter test                 # tests unitaires et de widgets
flutter analyze              # analyse statique (règles dans analysis_options.yaml)
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8080 --dart-define=GOOGLE_CLIENT_ID=<client ID web>
flutter build web --dart-define=API_BASE_URL=... --dart-define=GOOGLE_CLIENT_ID=...
```

| Variable (`--dart-define`) | Rôle |
| --- | --- |
| `API_BASE_URL` | Racine du backend, `http://localhost:8080` par défaut |
| `GOOGLE_CLIENT_ID` | Client ID OAuth **web** : connexion sur le web, et « server client ID » sur Android pour que le backend reçoive la même audience |

Le backend doit autoriser l'origine du frontend web : `CORS_ALLOWED_ORIGINS` (par exemple `http://localhost:5000` avec `flutter run -d chrome --web-port 5000`).

## Client de l'API

`packages/library_api` est **généré** depuis `docs/api/openapi.yaml` (openapi-generator `dart-dio`, modèles `json_serializable`) : ne pas le modifier à la main.

```bash
cd backend && ./gradlew integrationTest      # régénère docs/api/openapi.yaml
./scripts/generate-api-client.sh             # régénère packages/library_api
```

Les champs non nullables côté Dart viennent des records Java : tout composant est obligatoire sauf s'il est annoté `@Nullable` (JSpecify).

## Structure

```
lib/
├── main.dart              application, thème, routeur
├── core/                  configuration, thème (couleurs et polices des maquettes), client HTTP, routes
├── features/
│   ├── add/               ajout d'un livre : ISBN, scan caméra ou webcam, confirmation, saisie manuelle
│   ├── auth/              connexion Google, état de session, écran de connexion
│   ├── books/             bibliothèque, liste d'envies, fiche livre (suivi, autres lecteurs, modification), couvertures
│   ├── home/              navigation (barre d'onglets mobile, menu latéral ≥ 1024 px)
│   └── settings/          réglages : profil, catégories, membres, déconnexion
└── shared/                widgets communs
test/                      tests (API simulée avec mocktail)
packages/library_api/      client généré
```

Connexion : `google_sign_in` fournit l'ID token Google ; l'app n'est connectée qu'une fois `GET /api/me` accepté (403 = compte non invité). Le token expire au bout d'une heure : un 401 renvoie à l'écran de connexion.
