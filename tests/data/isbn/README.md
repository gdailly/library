# Réponses réelles des API ISBN

Réponses brutes enregistrées depuis les API, utilisées par les tests de lecture du backend
(`OpenLibraryClientTest`, `BnfClientTest`). Elles détectent un changement de format des API et servent d'exemples réels.

| Fichier | ISBN | Particularité |
| --- | --- | --- |
| `open-library-9782070612758.json` | Le Petit Prince | date « March 2007 », couverture |
| `open-library-9782070360024.json` | L'Étranger | date « 07-01-1972 », pas de couverture |
| `open-library-9782253004226.json` | Germinal | éditeur entre crochets (convention de catalogue) |
| `open-library-9780547928227.json` | The Hobbit | édition anglaise |
| `open-library-9790000000001.json` | (inconnu) | réponse vide `{}` |
| `bnf-9782070360024.xml` | L'Étranger | notice ancienne trouvée par son ISBN-10, « 1 volume 191 p » |
| `bnf-9782072730672.xml` | Les misérables | « DL 2017 », « 1 vol. (1339 p.) », préfacier en 702 (ignoré) |
| `bnf-9790000000001.xml` | (inconnu) | aucune notice |

Les réponses BnF ont été reconstituées à partir des vraies réponses du 2026-11-01, réduites aux zones lues
(le réseau de l'environnement de développement ne permettait pas de les télécharger telles quelles).

Enregistrer une réponse :

```bash
curl -s -A "Library/1.0" "https://openlibrary.org/api/books?bibkeys=ISBN:<isbn>&format=json&jscmd=data" -o open-library-<isbn>.json
```

BnF :

```bash
curl -s "https://catalogue.bnf.fr/api/SRU?version=1.2&operation=searchRetrieve&recordSchema=unimarcxchange&maximumRecords=1&query=bib.isbn%20all%20%22<isbn13>%22%20or%20bib.isbn%20all%20%22<isbn10>%22" -o bnf-<isbn13>.xml
```

Google Books : à enregistrer avec une clé d'API (`&key=...`, à ne jamais laisser dans le fichier),
le quota anonyme étant épuisé. Format : `google-books-<isbn>.json`.
