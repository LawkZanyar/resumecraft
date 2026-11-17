# ResumeCraft AI

An AI-powered resume builder and personal career assistant, built with Flutter for Android
(code kept portable to iOS).

**Team:** Lawk Zaniar (platform and security), Pasha Mariwan (resumes), Hananeh Mohsen (AI and voice),
Fatemeh Kamal (jobs and tracker).

## Run it

```bash
flutter pub get
flutter run --dart-define=USE_FAKES=true   # sample data, no accounts needed
```

`USE_FAKES=true` (the default) uses in-memory fake repositories and clearly labeled sample data.
A sample account is offered on the login screen.

## Architecture

Feature-first clean architecture:

```text
lib/
  app/        app widget, router, routes, theme, navigation shell
  core/       config, Result/Failure, validators, shared widgets
  shared/     domain entities + repository contracts, fakes and sample data
  features/   one folder per feature: data/ domain/ presentation/
```

State management is Riverpod; navigation is go_router with a five-tab shell
(Home, My Resumes, AI Career Assistant, Jobs, Profile).

## Checks

```bash
flutter analyze
flutter test
```

CI runs both on every pull request (`.github/workflows/ci.yml`).
