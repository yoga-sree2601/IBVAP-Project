# IBVAP — Full-Stack Prototype

Intelligent Border Video Analytics Platform. Flutter frontend + FastAPI
backend + SQLite database, wired together with real CRUD for cameras,
alerts and the virtual fence.

```
ibvap_fullstack/
  backend/     FastAPI + SQLite — REST API, see backend/README.md
  frontend/    Flutter app — same design as the HTML prototype, see frontend/README.md
```

## Fastest path to running this

```bash
# 1) backend
cd backend
python -m venv venv && source venv/bin/activate   # Windows: venv\Scripts\activate
pip install -r requirements.txt
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# 2) frontend (new terminal)
cd frontend
flutter create .          # one-time — generates android/ios/web folders
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000   # Android emulator
```

Full details, troubleshooting, and how to get this onto a physical phone,
Chrome/laptop, or a shared deployed URL for your whole team are in each
folder's own README — **read `frontend/README.md` before your first run**,
it covers a required one-time setup step.

## What's real vs. what's demo

- **Real, backend + database-backed, full CRUD:** Cameras, Alerts, Virtual
  Fence (zones + settings).
- **Design-complete, local/demo data:** ANPR log, Night Detection, Sector
  Map, Analytics, Settings toggles. These match the prototype's design and
  transitions exactly; hooking them to the database follows the identical
  pattern already used for cameras/alerts (add a table in
  `backend/app/models.py`, a couple of routes in `backend/app/main.py`, and
  an `ApiService` method) — happy to wire these up too if your team needs
  them database-backed for the final round.
- **Auth:** a demo login (any non-empty operator ID + passcode) — swap
  `backend/app/main.py`'s `/auth/login` for real credential checks before
  using this beyond a hackathon demo.

## Deploying so your whole team shares one instance

See `backend/README.md` → "Deploying so your whole team can hit one shared
URL" for a free Render.com deploy (a few clicks, no server management).
Once deployed, every teammate runs the Flutter app with
`--dart-define=API_BASE_URL=<your deployed URL>` and everyone sees the same
live data.
