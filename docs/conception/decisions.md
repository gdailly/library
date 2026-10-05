# Décisions

Dernière mise à jour : 2026-10-05

| Sujet | Décision |
| --- | --- |
| Backend | Java 25 (LTS) / Spring Boot 4, conteneurisé Docker |
| Base de données | MariaDB, migrations Flyway |
| Frontend | Flutter, cibles web et Android |
| Hors-ligne | Pas de mode hors-ligne |
| Authentification | Google Sign-In (ID token) validé par Spring Security, liste blanche d'e-mails |
| Partage | Bibliothèque partagée (rôles OWNER / MEMBER) ; statut de lecture et note propres à chaque utilisateur |
| Lot 1 | Scan ISBN, ajout manuel, statut, catégories, note + avis, liste d'envies, recherche, couvertures et vignettes |
| Vignettes | Couverture stockée côté backend (volume `covers`), tailles thumb 160×240 et medium 480×720 en WebP, URL signées 24 h |
| Métadonnées ISBN | Open Library, puis Google Books en secours, avec cache |
| Reconnaissance IA | Lots 2 et 3, Claude Haiku 4.5 (`claude-haiku-4-5`), clé `ANTHROPIC_API_KEY`, désactivée par défaut |
| Dépôt | GitHub `gdailly/library` |
