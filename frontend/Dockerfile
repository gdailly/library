# Flutter web app served by Caddy, which also forwards /api to the backend (see infra/caddy/Caddyfile).
FROM debian:bookworm-slim AS build
ARG FLUTTER_VERSION=3.47.6
RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates curl git unzip xz-utils \
 && rm -rf /var/lib/apt/lists/*
RUN git clone --depth 1 --branch "$FLUTTER_VERSION" https://github.com/flutter/flutter.git /opt/flutter
ENV PATH="/opt/flutter/bin:$PATH"
RUN flutter config --no-analytics --enable-web > /dev/null && flutter precache --web

WORKDIR /app
COPY pubspec.yaml pubspec.lock ./
COPY packages packages
RUN flutter pub get
COPY . .
# Only the public OAuth client ID goes into the bundle. API_BASE_URL is left out: the app calls its own origin.
ARG GOOGLE_CLIENT_ID
RUN test -n "$GOOGLE_CLIENT_ID" || (echo "GOOGLE_CLIENT_ID is required" >&2 && exit 1)
RUN flutter build web --release --dart-define=GOOGLE_CLIENT_ID="$GOOGLE_CLIENT_ID"

FROM caddy:2.10-alpine
COPY --from=build /app/build/web /srv
