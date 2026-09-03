# IBVAP Frontend (Flutter)

Same design, transitions and screens as the HTML prototype — now a real
Flutter app wired to the FastAPI backend (`../backend`) for cameras, alerts
and the virtual fence, all with live CRUD.

## ⚠️ One-time setup step (important)

This folder ships `lib/` (all the app code) and `pubspec.yaml`, but **not**
the `android/`, `ios/`, `web/` platform folders. Those are large, mostly
boilerplate, and version-specific to whatever Flutter SDK you have installed
— generating them by hand risks a mismatched Gradle/AGP setup that fails to
build. The correct, standard way to add them is to let your own Flutter SDK
generate them:

```bash
cd frontend
flutter create .
```

This is safe — it only **adds** the missing `android/`, `ios/`, `web/` (etc.)
folders matching your installed Flutter version; it will **not** touch or
overwrite anything in `lib/` or `pubspec.yaml`. Do this once, right after
unzipping.

Then:

```bash
flutter pub get
```

## Allow HTTP (cleartext) traffic to the backend

The backend runs on plain `http://`, not `https://`. Android blocks
cleartext traffic by default for apps targeting API 28+, so after running
`flutter create .`, open `android/app/src/main/AndroidManifest.xml` and add
`android:usesCleartextTraffic="true"` to the `<application>` tag:

```xml
<application
    android:usesCleartextTraffic="true"
    android:label="ibvap"
    ...>
```

(Only needed for real HTTP backends during development — not an issue once
the backend is deployed behind HTTPS, e.g. on Render.)

## Run it — Android Studio (mobile / emulator)

1. Open the `frontend` folder in Android Studio.
2. Start the backend first (`../backend`, see its README) — the app needs
   it reachable to log in and load data.
3. Pick a device (emulator or a physical phone on the same Wi-Fi).
4. Set the backend URL via a run configuration argument, or just run from
   the terminal:

   ```bash
   # Android emulator (backend running on your same laptop):
   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000

   # Physical phone on the same Wi-Fi as your laptop:
   flutter run --dart-define=API_BASE_URL=http://<your-laptop-LAN-IP>:8000
   ```

   To set this permanently in Android Studio instead of typing it every
   time: **Run → Edit Configurations → Additional run args** →
   `--dart-define=API_BASE_URL=http://10.0.2.2:8000`.

## Run it — laptop / browser

```bash
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000
```

Works the same as mobile — same design, same transitions, same CRUD,
talking to the same backend.

(Want a native Windows/macOS/Linux desktop window instead of Chrome? Run
`flutter create .` — which you already did above — and it also adds those
platform folders; then `flutter run -d windows` / `-d macos` / `-d linux`.)

## What's wired to the backend

- **Login** — calls `POST /auth/login`, then loads cameras, alerts and
  fence data before entering the dashboard.
- **Cameras** — full CRUD (`GET/POST/PUT/DELETE /cameras`), each card shows
  its live feed thumbnail (night-vision tint for cameras flagged `night`).
- **Alerts** — full CRUD (`GET/POST/PUT/DELETE /alerts`), severity filters.
- **Virtual Fence** — zones CRUD (`/fence/zones`) + sensitivity/toggles/arm
  state persisted via `/fence/settings`.
- **ANPR, Night Detection, Sector Map, Analytics, Settings** — same design
  as the prototype; currently local/demo data (not database-backed) since
  the problem statement's core CRUD surfaces are cameras/alerts/fence. Wiring
  these to the backend later just means adding matching tables + endpoints
  (same pattern as `cameras`/`alerts`) and an `ApiService` method.

## Sharing this with your team

Once the backend is deployed (see `../backend/README.md` for a free Render
deploy), everyone on the team runs:

```bash
flutter run --dart-define=API_BASE_URL=https://your-deployed-backend-url
```

— same app, same shared database, no local backend needed.

## Project structure

```
lib/
  theme/            color tokens + fonts (Sora / JetBrains Mono / Inter)
  models/           SurveillanceCamera, AlertItem, FenceZone, FenceSettings
  services/         ApiService — all HTTP calls to the backend live here
  providers/        ThemeProvider, CameraProvider, AlertProvider, FenceProvider
                     (all three data providers are API-backed: fetchAll() +
                     async CRUD methods that call ApiService then update state)
  screens/          one file per page
  widgets/          sidebar, camera/alert/zone form dialogs
```
