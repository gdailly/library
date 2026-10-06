#!/usr/bin/env bash
# Runs the Flutter web app in Chrome (or the browser given as first argument: edge, web-server),
# connected to the backend of scripts/dev-backend.sh.
# Only API_BASE_URL and GOOGLE_CLIENT_ID are passed to the app: the other values of .env.local
# are secrets that must never end up in the JavaScript bundle.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ENV_FILE="$ROOT/.env.local"
DEVICE="${1:-chrome}"

value() {
  grep -E "^$1=" "$ENV_FILE" | tail -1 | cut -d= -f2- | tr -d '\r'
}

if [ ! -f "$ENV_FILE" ]; then
  echo "Fichier .env.local introuvable : copier infra/.env.example en .env.local et le compléter." >&2
  exit 1
fi
CLIENT_ID="$(value GOOGLE_CLIENT_ID)"
if [ -z "$CLIENT_ID" ] || [[ "$CLIENT_ID" == *A_RENSEIGNER* ]]; then
  echo "GOOGLE_CLIENT_ID n'est pas renseigné dans .env.local." >&2
  exit 1
fi

FLUTTER="$(command -v flutter || true)"
FLUTTER="${FLUTTER:-$HOME/dev/flutter/bin/flutter}"

cd "$ROOT/frontend"
"$FLUTTER" run -d "$DEVICE" \
  --web-port "$(value WEB_PORT)" \
  --dart-define=API_BASE_URL="$(value API_BASE_URL)" \
  --dart-define=GOOGLE_CLIENT_ID="$CLIENT_ID"
