# Cahier de recette — Lot 1 (MVP)

Version : 2026-10-13 · Application : Library (backend Spring Boot + Flutter web et Android)

Objectif : vérifier à la main, sur la stack locale, que chaque fonction du lot 1 marche de bout en bout
avec de vraies données (Google, Open Library, Google Books). Cocher chaque cas, noter les anomalies en bas.

Légende du résultat : ✅ conforme · ❌ anomalie (numéroter dans le tableau des anomalies) · ⏭ non testé.

## 0. Préparation

| # | Étape | Attendu | Résultat |
| --- | --- | --- | --- |
| 0.1 | Copier `infra/.env.example` en `.env.local` à la racine et le compléter : `GOOGLE_CLIENT_IDS` et `GOOGLE_CLIENT_ID` (client OAuth web, origine `http://localhost:5000`), `BOOTSTRAP_OWNER_EMAIL` (ton e-mail Google), `CORS_ALLOWED_ORIGINS=http://localhost:5000`, `COVER_URL_SECRET` (chaîne aléatoire longue), `GOOGLE_BOOKS_API_KEY` | Fichier complet, aucun `change-me` restant | |
| 0.2 | `scripts/dev-backend.sh` (Git Bash) | « prêt sur http://localhost:8080 » ; `docker compose ps` montre `mariadb` healthy et `backend` up | |
| 0.3 | Ouvrir `http://localhost:8080/actuator/health` | `{"status":"UP"}` | |
| 0.4 | `scripts/dev-web.sh` | L'app s'ouvre dans Chrome sur `http://localhost:5000` | |
| 0.5 | Android : `flutter run` sur un téléphone avec `--dart-define=API_BASE_URL=http://<IP du PC>:8080` et `GOOGLE_CLIENT_ID` | L'app démarre sur l'écran Connexion | |
| 0.6 | Préparer un second compte Google (pour les tests de partage) et 5 à 10 livres physiques, dont un ancien (ISBN-10) et un sans code-barres | — | |

ISBN de référence (`tests/data/isbn`) : 9782070612758 (Le Petit Prince, avec couverture), 9782070360024 (L'Étranger, sans couverture),
9782253004226 (Germinal), 9780547928227 (The Hobbit), 9790000000001 (inconnu).

## 1. Connexion et accès

| # | Scénario | Attendu | Web | Android |
| --- | --- | --- | --- | --- |
| 1.1 | Ouvrir l'app sans être connecté | Écran Connexion, slogan « Ta bibliothèque, partagée avec tes proches. », bouton officiel Google | | |
| 1.2 | Se connecter avec l'e-mail `BOOTSTRAP_OWNER_EMAIL` | Arrivée sur Bibliothèque (vide), « Ma bibliothèque » créée, rôle Propriétaire dans Réglages | | |
| 1.3 | Se connecter avec un compte Google non invité | Message « Accès réservé aux comptes invités par le propriétaire. », pas d'accès aux écrans | | |
| 1.4 | Annuler la fenêtre Google | Retour sur Connexion sans plantage | | |
| 1.5 | Recharger la page (web) / relancer l'app (Android) | Session conservée ou reconnexion silencieuse | | |
| 1.6 | Laisser l'app ouverte plus d'une heure puis agir | Soit l'action passe, soit « Ta session a expiré, reconnecte-toi. » | | |
| 1.7 | Se déconnecter depuis Réglages | Retour sur Connexion ; les écrans protégés ne sont plus accessibles | | |
| 1.8 | Appeler `http://localhost:8080/api/books` sans jeton | 401 | | — |

## 2. Ajout par ISBN et scan

| # | Scénario | Attendu | Web | Android |
| --- | --- | --- | --- | --- |
| 2.1 | Ajouter un livre → saisir 9782070612758 | « Trouvé sur Open Library », titre, auteur, éditeur, année pré-remplis, couverture affichée | | |
| 2.2 | Valider « Ajouter à ma bibliothèque » | Le livre apparaît dans la grille avec sa couverture | | |
| 2.3 | Saisir un ISBN-10 (ex. 2070612759) | Normalisé en 978…, même résultat qu'en 13 chiffres | | |
| 2.4 | Saisir un ISBN avec tirets ou espaces | Accepté | | |
| 2.5 | Saisir « 12345 » | « Saisis un ISBN de 10 ou 13 chiffres. » | | |
| 2.6 | Saisir 9790000000001 | « Livre introuvable sur Open Library et Google Books : complète les informations. », formulaire vide avec l'ISBN | | |
| 2.7 | Saisir un ISBN connu seulement de Google Books (ex. livre récent) | « Trouvé sur Google Books » | | |
| 2.8 | Ressaisir un ISBN déjà dans la bibliothèque | Le livre existant est signalé avec « Voir la fiche », aucun formulaire d'ajout, pas de doublon | | |
| 2.9 | Scanner le code-barres (webcam sur le web, bouton flottant « Scanner » sur Android) | « Vise le code-barres au dos du livre », lecture EAN-13 puis écran de confirmation pré-rempli | | |
| 2.10 | Refuser l'accès à la caméra | « Caméra indisponible… », lien « Pas de code-barres ? Saisir l'ISBN » utilisable | | |
| 2.11 | « Ajouter et scanner le suivant » sur 3 livres d'affilée | Chaque livre est ajouté, le scanner se rouvre à chaque fois | | |
| 2.12 | Ajout manuel d'un livre sans ISBN | Titre obligatoire (« Le titre est obligatoire. »), le reste facultatif ; livre ajouté avec vignette générée (titre sur fond de couleur) | | |
| 2.13 | Champs invalides : pages = « abc », année = « deux mille » | « Le nombre de pages doit être un entier positif. », « L'année doit être un nombre. » | | |
| 2.14 | Choisir des catégories à l'ajout | Catégories enregistrées sur le livre | | |
| 2.15 | Couper le réseau du backend vers Internet puis rechercher un nouvel ISBN | « Recherche ISBN momentanément indisponible… », possibilité de saisir le livre | | — |

Cache ISBN (à vérifier en base ou dans les logs du backend) :

| # | Scénario | Attendu | Résultat |
| --- | --- | --- | --- |
| 2.16 | Rechercher deux fois le même ISBN | Une seule ligne dans `isbn_lookup`, aucun nouvel appel externe la 2e fois | |
| 2.17 | Rechercher un ISBN inconnu | Ligne `NOT_FOUND` dans `isbn_lookup` (valable 7 jours) | |
| 2.18 | Couverture d'un livre ajouté par ISBN | Un fichier nommé par SHA-256 dans `infra/data/covers`, plus ses vignettes WebP | |

## 3. Bibliothèque, recherche et filtres

| # | Scénario | Attendu | Web | Android |
| --- | --- | --- | --- | --- |
| 3.1 | Bibliothèque vide | Message d'état vide, invitation à ajouter un livre | | |
| 3.2 | Basculer grille / liste | Les deux vues affichent les mêmes livres | | |
| 3.3 | Rechercher par titre, par auteur, par ISBN (champ « Titre, auteur, ISBN… ») | Résultats corrects, insensibles à la casse et aux accents si possible | | |
| 3.4 | Filtrer par statut (À lire, En cours, Lu, Abandonné) | Filtre sur **mon** statut, pas celui des autres membres | | |
| 3.5 | Filtrer par catégorie et par note minimale | Résultats cohérents ; combinaisons de filtres possibles | | |
| 3.6 | Aucun résultat | « Aucun livre trouvé. » | | |
| 3.7 | Plus de 20 livres | Pagination ou chargement continu sans doublon ni trou | | |
| 3.8 | Les livres de la liste d'envies n'apparaissent pas dans la bibliothèque | Conforme | | |

## 4. Fiche livre et suivi de lecture

| # | Scénario | Attendu | Web | Android |
| --- | --- | --- | --- | --- |
| 4.1 | Ouvrir un livre | Fiche (web ≥ 1024 px : panneau à droite de la grille) : couverture, infos, résumé, catégories, « Mon suivi », « Les autres lecteurs » | | |
| 4.2 | Passer « Mon statut » à En cours | Date de début = aujourd'hui | | |
| 4.3 | Passer à Lu | Date de fin = aujourd'hui | | |
| 4.4 | Saisir une date de fin avant la date de début | « La date de fin précède la date de début. » | | |
| 4.5 | Noter 1 à 5 étoiles, puis « Pas de note » | Note enregistrée puis effacée | | |
| 4.6 | Écrire « Mon avis », quitter, revenir | Avis conservé | | |
| 4.7 | « Modifier les infos » : changer titre, auteurs (« Séparés par des virgules »), éditeur | Modifications visibles par tous les membres | | |
| 4.8 | Modifier l'ISBN vers celui d'un autre livre de la bibliothèque | « Un autre livre porte déjà cet ISBN. » | | |
| 4.9 | Remplacer la couverture par une photo (JPEG, PNG) | Nouvelle couverture affichée en vignette et en grand | | |
| 4.10 | Envoyer un fichier non image ou de plus de 10 Mo | « Format d'image non reconnu… » ou « Image vide ou trop volumineuse. » | | |
| 4.11 | Supprimer le livre | Confirmation « Le livre disparaît pour tous les membres, avec leurs notes et avis. » puis disparition | | |

## 5. Liste d'envies

| # | Scénario | Attendu | Web | Android |
| --- | --- | --- | --- | --- |
| 5.1 | Ajouter un livre avec « Ajouter à ma liste d'envies » | Apparaît dans Envies, pas dans Bibliothèque | | |
| 5.2 | Liste d'envies vide puis recherche sans résultat | « Aucune envie… » / « Aucune envie trouvée. » | | |
| 5.3 | Web : affichage en tableau | Colonnes lisibles, actions accessibles | | — |
| 5.4 | « Je l'ai » sur une envie | Le livre passe dans la bibliothèque | | |
| 5.5 | Le suivi de lecture est désactivé sur une envie | Message « Désactivé : le livre est dans la liste d'envies » | | |

## 6. Catégories (Réglages)

| # | Scénario | Attendu | Web | Android |
| --- | --- | --- | --- | --- |
| 6.1 | Ajouter une catégorie avec une couleur | Visible dans Réglages avec son nombre de livres | | |
| 6.2 | Nom vide | « Donne un nom à la catégorie. » | | |
| 6.3 | Nom déjà existant | Erreur de doublon (409) affichée proprement | | |
| 6.4 | Renommer / changer la couleur | Mise à jour sur les livres concernés | | |
| 6.5 | Supprimer une catégorie utilisée | Confirmation « Supprimer la catégorie ? », les livres restent, sans cette catégorie | | |

## 7. Membres et partage (deux comptes)

| # | Scénario | Attendu | Résultat |
| --- | --- | --- | --- |
| 7.1 | Propriétaire : inviter le second e-mail (« E-mail Google à inviter ») | Le membre apparaît dans « Membres de la bibliothèque » | |
| 7.2 | Inviter un e-mail déjà membre | « Cette personne est déjà membre. » | |
| 7.3 | Second compte : se connecter | Accès à la même bibliothèque, mêmes livres | |
| 7.4 | Second compte : mettre un statut et une note différents sur un livre | Chacun voit son propre suivi ; l'autre apparaît dans « Les autres lecteurs » | |
| 7.5 | Second compte (MEMBER) : tenter d'inviter ou de retirer | Action absente ou refusée (« Réservé au propriétaire de la bibliothèque. ») | |
| 7.6 | Second compte : ajouter un livre | Visible chez le propriétaire, « ajouté par » indique le second compte | |
| 7.7 | Propriétaire : retirer le second compte | Le second compte reçoit un refus d'accès à sa prochaine action | |
| 7.8 | Propriétaire seul : tenter de se retirer | « La bibliothèque doit garder au moins un propriétaire. » | |
| 7.9 | Après 7.7, ouvrir un livre ajouté par le membre retiré | Pas de plantage | |

## 8. Couvertures et URL signées

| # | Scénario | Attendu | Résultat |
| --- | --- | --- | --- |
| 8.1 | Web : copier l'URL d'une vignette et l'ouvrir dans un autre onglet | Image affichée (URL signée, sans jeton) | |
| 8.2 | Modifier un caractère de `sig` dans l'URL | 403 « Lien de couverture invalide ou expiré. » | |
| 8.3 | En-têtes de la réponse image | `Cache-Control` long et `ETag` présents ; second chargement servi depuis le cache | |
| 8.4 | Deux livres avec la même couverture (même ISBN dans deux bibliothèques, ou même image envoyée) | Un seul fichier sur le volume `covers` | |

## 9. Interface et ergonomie

| # | Scénario | Attendu | Résultat |
| --- | --- | --- | --- |
| 9.1 | Web : élargir puis réduire la fenêtre autour de 1024 px | Menu latéral au-dessus, barre 3 onglets + « Scanner » en dessous, sans perte d'état | |
| 9.2 | Couleurs et polices conformes aux maquettes (accent #1F5E4B, Bricolage Grotesque / Instrument Sans) | Conforme | |
| 9.3 | Cibles tactiles sur Android (étoiles, onglets, boutons) | Faciles à toucher (≥ 44 px) | |
| 9.4 | Textes en français, sans faute ni texte technique visible | Conforme | |
| 9.5 | Backend arrêté pendant l'utilisation | Message d'erreur et bouton « Réessayer », pas d'écran blanc | |

## 10. Exploitation

| # | Scénario | Attendu | Résultat |
| --- | --- | --- | --- |
| 10.1 | `docker compose down` puis `scripts/dev-backend.sh` | Livres, suivis et couvertures conservés | |
| 10.2 | Démarrer avec une base vide | Liquibase crée les tables, le propriétaire est recréé à la première connexion | |
| 10.3 | Aucun secret dans le bundle web (`frontend/build/web`, rechercher `COVER_URL_SECRET`, la clé Google Books) | Absents | |

## Anomalies

| N° | Cas | Plateforme | Description | Gravité (bloquante / gênante / mineure) | Statut |
| --- | --- | --- | --- | --- | --- |
| | | | | | |

## Bilan

- Date de la recette :
- Version testée (commit) :
- Décision : lot 1 accepté / accepté avec réserves / refusé
