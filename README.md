# MiamAI

[![CI](https://github.com/louisastori/MiamAI/actions/workflows/ci.yml/badge.svg)](https://github.com/louisastori/MiamAI/actions/workflows/ci.yml)
[![CD](https://github.com/louisastori/MiamAI/actions/workflows/cd.yml/badge.svg)](https://github.com/louisastori/MiamAI/actions/workflows/cd.yml)

MiamAI est un assistant culinaire mobile. L'utilisateur discute avec l'IA, choisit une recette, puis l'application prépare un panier basé sur des produits Leclerc Drive.

## État actuel

- `backend/` contient une API Spring Boot compilable avec fournisseurs simulés.
- `mobile/` contient l'application Flutter alignée avec la maquette.
- `openspec/changes/create-miamai-mvp/` contient le cadrage OpenSpec du MVP.

## Backend

Prérequis :

- Java 21
- Maven 3.9+

Commandes :

```powershell
cd backend
mvn test
mvn spring-boot:run
```

Smoke test HTTP après démarrage :

```powershell
powershell -NoProfile -File .\scripts\smoke-test.ps1
```

API locale :

```text
http://localhost:8080/api
```

Routes principales :

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

Prérequis :

- Flutter 3.47.0
- Android SDK pour le build Android

Commandes :

```powershell
cd mobile
flutter pub get
flutter run --dart-define=MIAMAI_API_BASE=http://localhost:8080/api
```

Pour l'émulateur Android :

```powershell
flutter run --dart-define=MIAMAI_API_BASE=http://10.0.2.2:8080/api
```

Pour un téléphone Android branché en USB avec `adb reverse tcp:8080 tcp:8080` :

```powershell
flutter run --dart-define=MIAMAI_API_BASE=http://127.0.0.1:8080/api
```

## CI/CD GitHub

La CI s'exécute sur les pushs vers `main`, les pull requests vers `main` et les tags `v*.*.*`.

Elle vérifie :

- les tests backend Spring Boot avec Java 21 ;
- `flutter analyze` ;
- `flutter test` ;
- le build d'un APK Android debug.

Le CD s'exécute sur les pushs vers `main`, les tags `v*.*.*` et le lancement manuel depuis GitHub Actions.

Il produit :

- `miamai-api.jar` pour le backend ;
- `miamai-android.apk` pour l'application mobile.

Sur un tag du type `v0.1.0`, le workflow crée ou met à jour une GitHub Release avec ces artefacts.

L'URL d'API compilée dans l'APK peut être définie avec la variable GitHub `MIAMAI_API_BASE` ou au lancement manuel du workflow CD. Par défaut, elle vaut :

```text
http://10.0.2.2:8080/api
```
