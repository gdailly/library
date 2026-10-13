# Infra

| Fichier | Rôle |
| --- | --- |
| `docker-compose.yml` | Développement : MariaDB + backend (port 8080), utilisé par `scripts/dev-backend.sh` |
| `docker-compose.prod.yml` | Serveur : MariaDB + backend + site web derrière Caddy (HTTPS automatique) |
| `caddy/Caddyfile` | Caddy : sert l'app Flutter web et transmet `/api` au backend |
| `.env.example` | Variables du développement, à copier en `.env.local` à la racine |
| `.env.prod.example` | Variables du serveur, à copier en `infra/.env` |
| `data/` | Volumes (base, couvertures, certificats), ignorés par Git |

Mise en place sur un serveur : [docs/deploiement.md](../docs/deploiement.md).
