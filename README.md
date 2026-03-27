# Mentimeeter Host App

Application Flutter pour piloter des quiz en mode host (animateur), avec une architecture claire et multi-plateforme.

## Apercu

Ce projet sert de tableau de bord host pour une experience type Mentimeter:

- gestion des sessions de quiz
- gestion de l'authentification host
- navigation structuree avec `go_router`
- architecture modulaire par fonctionnalite (`auth`, `quizzes`, `session`)

Le projet est configure pour Android, iOS, Web, Windows, Linux et macOS.

## Stack technique

- Flutter (SDK Dart >= 3.0.0 < 4.0.0)
- State management: `flutter_bloc` / `bloc`
- Navigation: `go_router`
- Equality helpers: `equatable`
- Linting: `flutter_lints`

## Structure du projet

```text
lib/
	main.dart
	core/
		mock_data.dart
		router.dart
		theme.dart
	features/
		auth/
		quizzes/
		session/
```

## Prerequis

- Flutter SDK installe
- Dart SDK (inclus avec Flutter)
- Un editeur comme VS Code ou Android Studio

Verifier l'installation:

```bash
flutter doctor
```

## Installation

```bash
git clone https://github.com/Maher-bouchrara/MentimeeterHostApp.git
cd MentimeeterHostApp
flutter pub get
```

## Lancement

### 1) Lister les devices

```bash
flutter devices
```

### 2) Lancer l'application

```bash
flutter run
```

Pour le web:

```bash
flutter run -d chrome
```

## Build production

APK Android:

```bash
flutter build apk --release
```

Web:

```bash
flutter build web
```

Windows:

```bash
flutter build windows
```

## Qualite de code

Analyser le projet:

```bash
flutter analyze
```

Lancer les tests:

```bash
flutter test
```

## Git et collaboration

Le projet inclut un `.gitignore` adapte a Flutter pour exclure:

- artefacts de build
- fichiers IDE locaux
- fichiers temporaires
- fichiers potentiellement sensibles (`.env`)

## Roadmap possible

- integration d'un backend temps reel (WebSocket/Firebase)
- persistance des quiz et des resultats
- dashboard analytics en direct
- gestion des roles (host/co-host)

## Licence

Projet prive/academique. Adapter la licence selon vos besoins avant publication.
