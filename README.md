# Habla – Learn Spanish (A1–B2)

Modern, beautiful Spanish learning app with a warm red–orange–yellow palette. Includes free sections and a PRO (paid) learning path, plus weekly teacher video news. Designed for web deployment via GitHub Pages; can target mobile later with the same Flutter codebase.

## Features
- A1–B2 learning path with free and PRO lessons
- Teacher video news feed (some free, some PRO)
- Level selector and progress tracking (stored locally)
- Modern Material 3 UI with gradients and Google Fonts
- Deployed automatically to GitHub Pages with GitHub Actions

## Quick start (locally)
Prerequisites: Flutter (stable) with web enabled.

```bash
flutter config --enable-web
flutter pub get
flutter run -d chrome
```

## Deploy to GitHub Pages
1. Create a repository and push this project. Ensure your default branch is `main`.
2. GitHub Actions will build and deploy automatically on push to `main`.
3. In the repo settings, under Pages, ensure the source is set to "GitHub Actions".

The workflow uses `subosito/flutter-action` to install Flutter, builds the web app, and publishes the `build/web` directory to Pages.

## Customizing content
- Lessons: `assets/content/lessons.json`
- News: `assets/content/news.json`

Mark items with `"isPaid": true` to gate behind the PRO paywall. The web demo uses a mock subscription toggle in Settings or the Paywall to unlock.

## Notes
- For production payments, integrate platform billing (IAP) or Stripe Checkout on the web. The current implementation uses a mock subscription.
- The same codebase can be built for iOS/Android later.