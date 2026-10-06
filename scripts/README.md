# Scripts

À lancer depuis Git Bash, à la racine du dépôt.

| Script | Rôle |
| --- | --- |
| `dev-backend.sh` | Démarre MariaDB et le backend (reconstruit depuis les sources) avec docker compose et `.env.local` |
| `dev-web.sh [chrome\|edge]` | Lance l'app Flutter web sur `http://localhost:5000`, reliée au backend ; ne lui transmet que `API_BASE_URL` et `GOOGLE_CLIENT_ID` |
| `generate-api-client.sh` | Génère le client Dart `frontend/packages/library_api` depuis `docs/api/openapi.yaml` (Java et Flutter requis) |

Configuration locale : `.env.local` à la racine (modèle commenté : `infra/.env.example`), ignoré par Git.
Les outils téléchargés par les scripts sont mis en cache dans `scripts/.cache/` (ignoré par Git).
