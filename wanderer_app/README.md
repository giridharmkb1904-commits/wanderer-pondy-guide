# Wanderer — AI Guide to Pondicherry

A text-first, premium mobile guide to Pondicherry. Ask the guide about cafés, beaches, heritage walks, French-quarter food, Auroville experiences, and local wisdom. Opens Google Maps on tap.

## Get the APK

**Automatic builds:** Every push to `main` builds a release APK and publishes it as a GitHub Release and as a workflow artifact.

1. Push this repo to GitHub.
2. Go to the **Actions** tab → the latest "Build Release APK" run.
3. Download `wanderer-release-apk` from **Artifacts**, or grab the APK from the latest **Release**.

## Build locally

```bash
flutter pub get
flutter build apk --release
# output: build/app/outputs/flutter-apk/app-release.apk
```

Requires Flutter 3.27.0+ and Android SDK.

## Stack

- Flutter 3 + Dart
- Riverpod (state), go_router (nav), flutter_animate (motion)
- Local knowledge brain (`lib/core/brain/pondy_brain.dart`) — no backend required
- Google Maps via `url_launcher` (no API key needed)
