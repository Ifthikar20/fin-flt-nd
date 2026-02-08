# Fynda Flutter App

AI-powered deal discovery. Snap a photo, find the best deals.

## Features

- 📸 **Photo Search** — Take a photo of any item, AI identifies it and finds deals
- 🔍 **Smart Search** — Text search across all major marketplaces
- ❤️ **Save Favorites** — Save deals for later
- 🔔 **Price Alerts** — Get notified when prices drop
- 📋 **Storyboards** — Share your fashion finds
- 🔐 **Auth** — Email, Google, and Apple sign-in

## Architecture

```
lib/
├── config/          # API configuration
├── theme/           # Dark premium design system
├── models/          # Data models (Deal, User, PriceAlert, Storyboard)
├── services/        # API layer (Dio + JWT interceptor)
├── providers/       # Riverpod state management
├── router/          # GoRouter navigation
├── screens/         # Full-page views (12 screens)
└── widgets/         # Reusable components
```

## Setup

```bash
flutter pub get
flutter run
```

## API

Connects to the Fynda Mobile API at `api.fynda.shop/api/mobile/`.
See `docs/MOBILE_API.md` in the backend repo for full endpoint documentation.
