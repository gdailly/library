# Livre — gestion de bibliothèque personnelle

Application pour cataloguer ses livres, suivre ses lectures et les partager avec ses proches.
Ajout rapide par scan du code-barres ISBN, puis reconnaissance de couverture et d'étagère par IA (Claude).

## Stack

| Couche | Technologie |
| --- | --- |
| Backend | Java 25 (LTS), Spring Boot 4, Maven |
| Base de données | MariaDB + Flyway |
| Frontend | Flutter (web + Android) |
| Authentification | Google Sign-In, liste blanche d'e-mails |
| Reconnaissance IA | Claude Haiku 4.5 via `com.anthropic:anthropic-java` |
| Déploiement | Docker / docker-compose |

## Organisation du dépôt

```
library/
├── docs/                 Documentation du projet
│   ├── conception/       Cadrage, décisions, modèle de données
│   ├── maquettes/        Maquettes des écrans (exports, captures)
│   └── api/              Contrat OpenAPI et exemples d'appels
├── backend/              API Spring Boot (code + tests unitaires et d'intégration)
├── frontend/             Application Flutter (code + tests widget)
├── tests/                Tests transverses
│   ├── e2e/              Scénarios de bout en bout (app + API + base)
│   ├── plans/            Plans et cahiers de recette manuels
│   └── data/             Jeux de données de test (ISBN, photos de couvertures)
├── infra/                docker-compose, variables d'environnement, déploiement
└── scripts/              Scripts utilitaires (démarrage local, sauvegarde base…)
```

## Démarrage rapide

À venir avec le squelette du projet (`infra/docker-compose.yml`).

## Documentation

- Document de conception (vivant) : https://claude.ai/code/artifact/9b4d471f-628b-4ad6-821f-5cdb1c9c75f7
- Décisions : [docs/conception/decisions.md](docs/conception/decisions.md)
