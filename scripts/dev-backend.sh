#!/usr/bin/env bash
# Starts MariaDB and the backend (rebuilt from the sources) with the values of .env.local.
# Stop:  docker compose -f infra/docker-compose.yml --env-file .env.local down
# Logs:  docker compose -f infra/docker-compose.yml --env-file .env.local logs -f backend
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ENV_FILE="$ROOT/.env.local"

if [ ! -f "$ENV_FILE" ]; then
  echo "Fichier .env.local introuvable : copier infra/.env.example en .env.local et le compléter." >&2
  exit 1
fi
if grep -qE '^GOOGLE_CLIENT_IDS=.*A_RENSEIGNER' "$ENV_FILE"; then
  echo "GOOGLE_CLIENT_IDS n'est pas renseigné dans .env.local." >&2
  exit 1
fi

docker compose -f "$ROOT/infra/docker-compose.yml" --env-file "$ENV_FILE" up -d --build

printf 'Attente du backend'
for _ in $(seq 1 60); do
  if curl -fs http://localhost:8080/actuator/health > /dev/null; then
    echo " : prêt sur http://localhost:8080"
    exit 0
  fi
  printf '.'
  sleep 2
done
echo " : pas de réponse, voir les logs du conteneur backend." >&2
exit 1
