# MiamAI mobile

Application Flutter du MVP MiamAI.

Identifiant Android :

```text
fr.miamai.app
```

## Lancement

```powershell
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

## Vérifications

```powershell
flutter analyze
flutter test
flutter build apk --debug
flutter build apk --release
```
