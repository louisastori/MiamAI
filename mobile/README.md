# MiamAI mobile

Application Flutter du MVP MiamAI.

## Lancement

```powershell
flutter pub get
flutter run --dart-define=MIAMAI_API_BASE=http://localhost:8080/api
```

Pour l'émulateur Android, utiliser plutôt :

```powershell
flutter run --dart-define=MIAMAI_API_BASE=http://10.0.2.2:8080/api
```

## Vérifications

```powershell
flutter analyze
flutter test
```
