# Clarity — Personal Student Life OS

A premium Apple-style student life organizer built with React, Vite, Framer Motion, and Capacitor for iOS.

## Features

- **Home Dashboard** — Greeting, weather, summary rings, next event countdown, activity feed
- **Mind** — Life targets, thought channels (text/photo/voice), Apple Notes-style journal
- **Daily** — Lessons, sleep tracking, social media limits, habit streaks
- **World** — Movies (OMDb), music (iTunes), books (Google Books), YouTube organizer
- **Calendar** — Month/week/agenda views with event CRUD and integrations
- **Settings** — Theme, accent color, export/import, notifications

## Quick Start (Windows / Web)

```bash
cd C:\Users\Hossein\Projects\clarity
npm install
cp .env.example .env   # Add your OMDb API key for movie search
npm run dev
```

Open http://localhost:5173

## Environment Variables

Copy `.env.example` to `.env`:

```
VITE_OMDB_API_KEY=your_key_here
```

Get a free key at https://www.omdbapi.com/apikey.aspx

## Build for Production

```bash
npm run build
npm run preview
```

## iOS (Capacitor) — Requires macOS

Capacitor iOS projects must be built on a Mac with Xcode installed.

```bash
# On any platform — build web assets
npm run build

# Add iOS platform (first time, on Mac)
npx cap add ios

# Sync web build to native project
npx cap sync ios

# Open in Xcode
npx cap open ios
```

### Info.plist permissions (add on Mac)

In `ios/App/App/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Clarity uses your location to show local weather.</string>
<key>NSMicrophoneUsageDescription</key>
<string>Clarity records voice memos in thought channels.</string>
```

Enable Push Notifications capability in Xcode for local notification reminders.

### TestFlight / App Store

1. Open project in Xcode
2. Select your Team under Signing & Capabilities
3. Product → Archive
4. Distribute via App Store Connect

## Tech Stack

- React 19 + TypeScript + Vite
- Framer Motion (spring animations)
- Tailwind CSS v4
- Zustand + localStorage persistence
- Recharts
- Capacitor 8 (Haptics, Geolocation, Local Notifications)

## Data

All data is stored locally in `localStorage` under key `clarity-v1`. Use Settings → Export JSON to back up your data.

## License

Private — personal use.
