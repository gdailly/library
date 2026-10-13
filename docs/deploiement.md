# Déployer Library sur un serveur

Ce guide installe l'application complète (site web, API, base de données) sur un serveur Linux avec Docker.
Il ne suppose aucune connaissance des certificats : le serveur web **Caddy** s'en occupe seul.

## Ce qui tourne sur le serveur

```
Internet ──► Caddy (ports 80 / 443) ──┬──► site web Flutter (fichiers statiques)
             certificat HTTPS auto    └──► /api/* ──► backend Spring Boot ──► MariaDB
```

Tout est décrit dans `infra/docker-compose.prod.yml`. Seul Caddy est joignable de l'extérieur ; le backend et la base
restent dans le réseau privé de Docker.

## Deux façons d'exposer l'application

| | Mode IP (pour commencer) | Mode domaine (recommandé) |
| --- | --- | --- |
| Adresse | `http://203.0.113.10` | `https://livre.duckdns.org` |
| Chiffrement | Aucun (HTTP) | HTTPS, certificat Let's Encrypt gratuit, renouvelé tout seul |
| App Android | Oui | Oui |
| Site web | Non : Google refuse la connexion depuis une IP en HTTP | Oui |
| À faire en plus | Rien | Obtenir un nom de domaine (gratuit avec DuckDNS) |

On peut commencer en mode IP et passer au mode domaine plus tard : il suffit de changer une ligne (voir
[Passer du mode IP au mode domaine](#passer-du-mode-ip-au-mode-domaine)).

### Un certificat, c'est quoi ?

Pour qu'un navigateur affiche le cadenas, le site doit présenter un certificat signé par une autorité reconnue.
**Let's Encrypt** en délivre gratuitement, valables 90 jours, à condition de prouver qu'on contrôle le nom de domaine :
Let's Encrypt contacte le serveur sur le port 80 à l'adresse du domaine. **Caddy fait toute la démarche** au premier
démarrage, puis renouvelle le certificat avant son expiration. Il n'y a rien à installer ni à planifier.

Les seules conditions : un **nom de domaine** qui pointe vers l'IP du serveur, et les **ports 80 et 443** ouverts
depuis Internet. Un certificat ne peut pas être délivré pour une simple adresse IP, d'où le mode IP sans HTTPS.

## 1. Préparer le serveur

Il faut un serveur Linux (Debian, Ubuntu…) avec au moins **2 Go de mémoire** (4 Go conseillés : la première
construction de l'app Flutter et du backend est gourmande) et environ 5 Go de disque libre.

Installer Docker et son plugin Compose (méthode officielle) :

```bash
curl -fsSL https://get.docker.com | sudo sh
sudo usermod -aG docker $USER     # puis se déconnecter / reconnecter
docker compose version             # doit afficher une version 2.x
```

Ouvrir les ports dans le pare-feu du serveur s'il y en a un (exemple avec `ufw`) :

```bash
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 443/udp
```

**Serveur à la maison :** dans l'interface de la box, rediriger les ports **80** et **443** (TCP, et 443 UDP si
possible) vers l'adresse locale du serveur (par exemple `192.168.1.20`). Donner au serveur une adresse locale fixe
(bail DHCP réservé) pour que la redirection reste valable.

## 2. Récupérer le code

```bash
git clone https://github.com/gdailly/library.git
cd library
```

## 3. Choisir l'adresse

### Mode IP

Rien à faire : l'adresse sera `http://<IP publique du serveur>` (ou `http://<IP locale>` depuis la maison).
`SITE_ADDRESS` reste à `:80` à l'étape 5.

### Mode domaine avec DuckDNS (gratuit)

1. Aller sur https://www.duckdns.org et se connecter (compte Google par exemple).
2. Choisir un sous-domaine, par exemple `livre` → `livre.duckdns.org`, et cliquer sur **add domain**.
3. Dans le champ **current ip**, mettre l'IP publique du serveur (pour la connaître : `curl -4 ifconfig.me` sur le
   serveur), puis **update ip**.
4. Vérifier depuis n'importe quel ordinateur : `nslookup livre.duckdns.org` doit renvoyer cette IP.

**IP qui change (box Internet) :** DuckDNS doit être prévenu à chaque changement. Sur le serveur, ajouter cette ligne
avec `crontab -e` (le jeton est affiché en haut de la page DuckDNS une fois connecté) :

```
*/5 * * * * curl -fsS "https://www.duckdns.org/update?domains=livre&token=VOTRE_JETON&ip=" > /dev/null
```

Un nom de domaine acheté (OVH, Gandi…) convient aussi : créer un enregistrement **A** vers l'IP du serveur.

## 4. Configurer la connexion Google

Dans la [console Google Cloud](https://console.cloud.google.com/apis/credentials), projet utilisé pour Library :

1. **Écran de consentement OAuth** : tant que l'application est en mode « Test », ajouter chaque personne invitée dans
   **Utilisateurs test** (sinon Google bloque leur connexion).
2. **Client OAuth « Application Web »** (celui de `GOOGLE_CLIENT_ID`) → **Origines JavaScript autorisées** : ajouter
   l'adresse exacte du site, sans barre finale :
   - `https://livre.duckdns.org` (mode domaine) ;
   - garder `http://localhost:5000` pour le développement.

   Google n'accepte que des origines en `https://` ou `http://localhost` : c'est pourquoi le site web ne fonctionne
   pas en mode IP. Aucune « URI de redirection » n'est nécessaire.
3. **Client OAuth « Android »** (nécessaire pour l'app Android) : nom de package `com.gdailly.library` et empreinte
   **SHA-1** du certificat qui signe l'APK. L'APK est pour l'instant signé avec la clé de debug ; sur le PC qui
   construit l'APK :

   ```bash
   keytool -list -v -alias androiddebugkey -storepass android -keypass android \
     -keystore ~/.android/debug.keystore          # Windows : %USERPROFILE%\.android\debug.keystore
   ```

   Copier la ligne `SHA1:` dans la console. Ce client Android n'a pas à être déclaré dans `GOOGLE_CLIENT_IDS` :
   l'app demande un jeton émis pour le client web.

Les modifications de la console peuvent mettre quelques minutes à s'appliquer.

## 5. Renseigner la configuration

```bash
cp infra/.env.prod.example infra/.env
nano infra/.env
```

| Variable | Valeur |
| --- | --- |
| `SITE_ADDRESS` | `:80` en mode IP, `livre.duckdns.org` en mode domaine (sans `https://`) |
| `MARIADB_PASSWORD`, `MARIADB_ROOT_PASSWORD` | Mots de passe aléatoires : `openssl rand -base64 24` |
| `GOOGLE_CLIENT_ID` | Client ID web (`…apps.googleusercontent.com`) |
| `GOOGLE_CLIENT_IDS` | Le même client ID web |
| `BOOTSTRAP_OWNER_EMAIL` | Votre adresse Gmail : premier propriétaire de la bibliothèque |
| `GOOGLE_BOOKS_API_KEY` | Clé Google Books (recommandée) |
| `COVER_URL_SECRET` | Chaîne aléatoire : `openssl rand -base64 48` |

`infra/.env` contient des secrets : il est ignoré par Git, ne jamais le copier ailleurs que sur le serveur.

## 6. Démarrer

```bash
cd infra
docker compose -f docker-compose.prod.yml up -d --build
```

La première fois, la construction prend un moment (téléchargement de Flutter, de Gradle et des dépendances). Ensuite :

```bash
docker compose -f docker-compose.prod.yml ps            # les 3 services doivent être « running » / « healthy »
docker compose -f docker-compose.prod.yml logs -f web   # Caddy : obtention du certificat
```

En mode domaine, les logs de Caddy affichent `certificate obtained successfully` au bout de quelques secondes.
Ouvrir alors `https://livre.duckdns.org` : le cadenas apparaît et la connexion Google fonctionne.

En mode IP, vérifier que `http://<IP>/` affiche la page de connexion (le bouton Google y restera inutilisable).

## 7. Construire l'app Android

Sur le PC de développement (avec Flutter), depuis `frontend/` :

```bash
# Mode domaine
flutter build apk --release \
  --dart-define=API_BASE_URL=https://livre.duckdns.org \
  --dart-define=GOOGLE_CLIENT_ID=<client ID web>

# Mode IP
flutter build apk --release \
  --dart-define=API_BASE_URL=http://203.0.113.10 \
  --dart-define=GOOGLE_CLIENT_ID=<client ID web>
```

L'APK est dans `build/app/outputs/flutter-apk/app-release.apk` ; l'envoyer sur le téléphone et l'installer.

Android refuse le HTTP non chiffré par défaut : quand `API_BASE_URL` commence par `http://`, la construction
l'autorise automatiquement pour cette app. Avec une adresse en `https://`, il reste interdit. L'adresse est figée
dans l'APK : en changeant de mode, il faut reconstruire et réinstaller l'app.

## Passer du mode IP au mode domaine

1. Obtenir le domaine (étape 3) et déclarer l'origine dans la console Google (étape 4).
2. Dans `infra/.env`, remplacer `SITE_ADDRESS=:80` par `SITE_ADDRESS=livre.duckdns.org`.
3. `docker compose -f docker-compose.prod.yml up -d` (depuis `infra/`).
4. Reconstruire l'APK avec `API_BASE_URL=https://livre.duckdns.org`.

## Mettre à jour

```bash
cd library
git pull
cd infra
docker compose -f docker-compose.prod.yml up -d --build
```

Les migrations de base (Liquibase) s'appliquent au démarrage du backend. Pour libérer la place des anciennes
images : `docker image prune -f`.

## Sauvegarder

Toutes les données sont dans `infra/data/` :

| Dossier | Contenu |
| --- | --- |
| `data/mariadb/` | Base de données |
| `data/covers/` | Couvertures et vignettes |
| `data/caddy/` | Certificats (recréés automatiquement s'ils sont perdus) |

Sauvegarde cohérente de la base, sans arrêter le service (depuis `infra/`) :

```bash
docker compose -f docker-compose.prod.yml exec mariadb \
  sh -c 'mariadb-dump -u root -p"$MARIADB_ROOT_PASSWORD" "$MARIADB_DATABASE"' > livre-$(date +%F).sql
tar czf covers-$(date +%F).tar.gz data/covers
```

Copier ces fichiers hors du serveur.

## En cas de problème

| Symptôme | Cause probable |
| --- | --- |
| Caddy n'obtient pas de certificat (`challenge failed`, `timeout`) | Le domaine ne pointe pas vers le serveur (`nslookup`), ou le port 80 n'est pas ouvert / redirigé par la box |
| Trop de tentatives ratées (`rateLimited`) | Let's Encrypt limite les échecs : corriger la cause, attendre une heure, puis `docker compose … restart web` |
| Le bouton Google affiche une erreur d'origine | L'adresse du site n'est pas dans les **Origines JavaScript autorisées** (ou diffère : `https`, sans `/` final) |
| « Accès bloqué » chez une personne invitée | Elle n'est pas dans les **Utilisateurs test** de l'écran de consentement |
| Connexion refusée après Google (compte non invité) | L'e-mail n'est pas membre de la bibliothèque : l'inviter depuis **Réglages** |
| L'app Android ne se connecte pas à Google | Client OAuth Android absent ou SHA-1 différent de celui de la clé qui a signé l'APK |
| L'app Android n'arrive pas à joindre le serveur | `API_BASE_URL` incorrecte (reconstruire l'APK) ou ports fermés |
| Erreur 502 sur `/api` | Le backend démarre encore ou a planté : `docker compose … logs backend` |
