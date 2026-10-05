# Tests

| Niveau | Où | Outils |
| --- | --- | --- |
| Unitaires backend | `backend/src/test` | JUnit 5, Mockito |
| Intégration backend | `backend/src/test` | Spring Boot Test, Testcontainers (MariaDB) |
| Unitaires / widget frontend | `frontend/test` | flutter_test |
| Bout en bout | `tests/e2e` | Flutter integration_test ou Playwright (web) contre la stack docker-compose |
| Recette manuelle | `tests/plans` | Cahiers de recette par lot |
| Données de test | `tests/data` | ISBN de référence, photos de couvertures et d'étagères |
