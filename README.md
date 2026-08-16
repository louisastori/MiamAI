# MiamAI

MiamAI est un assistant culinaire mobile. L'utilisateur discute avec l'IA, choisit une recette, puis l'application prépare un panier basé sur des produits Leclerc Drive.

## État actuel

- `backend/` contient une API Spring Boot compilable avec fournisseurs simulés.
- `mobile/` contient le code source Flutter aligné avec la maquette.
- `openspec/changes/create-miamai-mvp/` contient le cadrage OpenSpec du MVP.

## Backend

Prérequis:

- Java 21
- Maven 3.9+

Commandes:

```powershell
cd backend
mvn test
mvn spring-boot:run
```

Smoke test HTTP après démarrage:

```powershell
powershell -NoProfile -File .\scripts\smoke-test.ps1
```

API locale:

```text
http://localhost:8080/api
```

Routes principales:

- `POST /api/assistant/chat`
- `POST /api/recipes/select`
- `PATCH /api/recipes/selected`
- `POST /api/baskets/build`
- `POST /api/baskets/build-selected`
- `POST /api/baskets/{basketId}/lines/{ingredientKey}/select`
- `POST /api/baskets/{basketId}/cheapest`
- `POST /api/baskets/{basketId}/handoff`
- `GET /api/preferences`
- `PUT /api/preferences`
- `GET /api/meals`

## Mobile

Le SDK Flutter n'est pas installé dans cet environnement. Le dossier `mobile/` contient le code source, mais les dossiers de plateforme (`android/`, `ios/`, `web/`, etc.) devront être générés avec Flutter.

Après installation de Flutter:

```powershell
cd mobile
flutter create .
flutter pub get
flutter run --dart-define=MIAMAI_API_BASE=http://10.0.2.2:8080/api
```

Pour un lancement web ou desktop local, utiliser plutôt:

```powershell
flutter run --dart-define=MIAMAI_API_BASE=http://localhost:8080/api
```
