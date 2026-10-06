# Réponses réelles des API ISBN

Réponses brutes enregistrées depuis les API, utilisées par les tests de lecture du backend
(`OpenLibraryClientTest`). Elles détectent un changement de format des API et servent d'exemples réels.

| Fichier | ISBN | Particularité |
| --- | --- | --- |
| `open-library-9782070612758.json` | Le Petit Prince | date « March 2007 », couverture |
| `open-library-9782070360024.json` | L'Étranger | date « 07-01-1972 », pas de couverture |
| `open-library-9782253004226.json` | Germinal | éditeur entre crochets (convention de catalogue) |
| `open-library-9780547928227.json` | The Hobbit | édition anglaise |
| `open-library-9790000000001.json` | (inconnu) | réponse vide `{}` |

Enregistrer une réponse :

```bash
curl -s -A "Library/1.0" "https://openlibrary.org/api/books?bibkeys=ISBN:<isbn>&format=json&jscmd=data" -o open-library-<isbn>.json
```

Google Books : à enregistrer avec une clé d'API (`&key=...`, à ne jamais laisser dans le fichier),
le quota anonyme étant épuisé. Format : `google-books-<isbn>.json`.
