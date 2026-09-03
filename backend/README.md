# IBVAP Backend (FastAPI + SQLite)

REST API + database for the IBVAP prototype. Powers cameras, alerts and the
virtual fence (zones + settings) with full CRUD, backed by a SQLite file
(`ibvap.db`, created automatically on first run and pre-seeded with the same
demo data as the prototype).

## Run locally

```bash
cd backend
python -m venv venv
source venv/bin/activate        # Windows: venv\Scripts\activate
pip install -r requirements.txt
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

API docs (interactive, auto-generated): http://localhost:8000/docs

## Connecting the Flutter app to this backend

The Flutter app needs your backend's URL. Where that URL points depends on
**where the backend is running relative to the device running the app**:

| Running Flutter on...                        | Backend runs on...      | Use this base URL                |
|-----------------------------------------------|--------------------------|-----------------------------------|
| Android **emulator**                           | same laptop              | `http://10.0.2.2:8000`            |
| Chrome / Flutter **web** (same laptop)          | same laptop              | `http://localhost:8000`           |
| Physical **phone** (same Wi-Fi as your laptop)  | your laptop              | `http://<laptop-LAN-IP>:8000`     |
| Anywhere                                        | deployed (Render/Railway)| `https://your-app.onrender.com`   |

Find your laptop's LAN IP with `ipconfig` (Windows) or `ifconfig`/`ip a`
(Mac/Linux) — look for something like `192.168.1.23`. Your phone and laptop
must be on the same Wi-Fi network.

Set the URL when launching Flutter:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.23:8000
```

(Details on wiring this into Android Studio's run configuration are in the
frontend README.)

## Endpoints

- `POST /auth/login` — demo login (accepts any non-empty operator id/passcode)
- `GET/POST /cameras`, `PUT/DELETE /cameras/{id}`
- `GET/POST /alerts`, `PUT/DELETE /alerts/{id}`
- `GET/POST /fence/zones`, `PUT/DELETE /fence/zones/{id}`
- `GET /fence/settings`, `PATCH /fence/settings`

## Deploying so your whole team can hit one shared URL

Easiest free option: **Render.com** (or Railway/Fly.io — same idea).

1. Push the `backend/` folder to a GitHub repo.
2. On Render: New → Web Service → connect the repo.
3. Build command: `pip install -r requirements.txt`
4. Start command: `uvicorn app.main:app --host 0.0.0.0 --port $PORT`
5. Deploy — Render gives you a public URL like `https://ibvap-api.onrender.com`.
6. Give that URL to your team; everyone runs Flutter with
   `--dart-define=API_BASE_URL=https://ibvap-api.onrender.com`.

Note: SQLite on Render's free tier resets on redeploy (ephemeral disk). Fine
for a demo/hackathon; swap `DATABASE_URL` in `app/database.py` for a managed
Postgres URL (Render/Neon/Supabase all have free tiers) if you need the data
to persist permanently.
