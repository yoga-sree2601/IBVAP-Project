import itertools
import secrets
from typing import List, Optional
from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session

from . import models, schemas
from .database import engine, get_db, SessionLocal, Base
from .seed import seed_if_empty

Base.metadata.create_all(bind=engine)
with SessionLocal() as _db:
    seed_if_empty(_db)

app = FastAPI(title="IBVAP API", version="1.0.0")

# Wide-open CORS - this is a hackathon/demo backend, tighten before any real deployment.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

_alert_seq = itertools.count(9922)


@app.get("/")
def root():
    return {"service": "IBVAP API", "status": "online"}


# ---------------------------------------------------------------- AUTH -----
@app.post("/auth/login", response_model=schemas.LoginResponse)
def login(payload: schemas.LoginRequest):
    if not payload.operator_id or not payload.passcode:
        raise HTTPException(status_code=401, detail="Invalid credentials")
    return schemas.LoginResponse(ok=True, operator_id=payload.operator_id, token=secrets.token_hex(16))


# ------------------------------------------------------------- CAMERAS -----
@app.get("/cameras", response_model=List[schemas.CameraOut])
def list_cameras(db: Session = Depends(get_db)):
    return db.query(models.Camera).all()


@app.post("/cameras", response_model=schemas.CameraOut, status_code=201)
def create_camera(payload: schemas.CameraCreate, db: Session = Depends(get_db)):
    cam = models.Camera(**payload.model_dump())
    db.add(cam)
    db.commit()
    db.refresh(cam)
    return cam


@app.put("/cameras/{camera_id}", response_model=schemas.CameraOut)
def update_camera(camera_id: int, payload: schemas.CameraCreate, db: Session = Depends(get_db)):
    cam = db.query(models.Camera).get(camera_id)
    if not cam:
        raise HTTPException(status_code=404, detail="Camera not found")
    for k, v in payload.model_dump().items():
        setattr(cam, k, v)
    db.commit()
    db.refresh(cam)
    return cam


@app.delete("/cameras/{camera_id}", status_code=204)
def delete_camera(camera_id: int, db: Session = Depends(get_db)):
    cam = db.query(models.Camera).get(camera_id)
    if not cam:
        raise HTTPException(status_code=404, detail="Camera not found")
    db.delete(cam)
    db.commit()


# -------------------------------------------------------------- ALERTS -----
@app.get("/alerts", response_model=List[schemas.AlertOut])
def list_alerts(db: Session = Depends(get_db)):
    return db.query(models.Alert).order_by(models.Alert.id.desc()).all()


@app.post("/alerts", response_model=schemas.AlertOut, status_code=201)
def create_alert(payload: schemas.AlertCreate, db: Session = Depends(get_db)):
    alert = models.Alert(
        ref_code=f"#AL-{next(_alert_seq)}",
        severity=payload.severity,
        title=payload.title,
        description=payload.description,
        timestamp="Just now",
    )
    db.add(alert)
    db.commit()
    db.refresh(alert)
    return alert


@app.put("/alerts/{alert_id}", response_model=schemas.AlertOut)
def update_alert(alert_id: int, payload: schemas.AlertCreate, db: Session = Depends(get_db)):
    alert = db.query(models.Alert).get(alert_id)
    if not alert:
        raise HTTPException(status_code=404, detail="Alert not found")
    alert.severity = payload.severity
    alert.title = payload.title
    alert.description = payload.description
    db.commit()
    db.refresh(alert)
    return alert


@app.delete("/alerts/{alert_id}", status_code=204)
def delete_alert(alert_id: int, db: Session = Depends(get_db)):
    alert = db.query(models.Alert).get(alert_id)
    if not alert:
        raise HTTPException(status_code=404, detail="Alert not found")
    db.delete(alert)
    db.commit()


# --------------------------------------------------------- VIRTUAL FENCE ---
@app.get("/fence/zones", response_model=List[schemas.FenceZoneOut])
def list_zones(db: Session = Depends(get_db)):
    return db.query(models.FenceZone).all()


@app.post("/fence/zones", response_model=schemas.FenceZoneOut, status_code=201)
def create_zone(payload: schemas.FenceZoneCreate, db: Session = Depends(get_db)):
    zone = models.FenceZone(**payload.model_dump())
    db.add(zone)
    db.commit()
    db.refresh(zone)
    return zone


@app.put("/fence/zones/{zone_id}", response_model=schemas.FenceZoneOut)
def update_zone(zone_id: int, payload: schemas.FenceZoneCreate, db: Session = Depends(get_db)):
    zone = db.query(models.FenceZone).get(zone_id)
    if not zone:
        raise HTTPException(status_code=404, detail="Zone not found")
    zone.name = payload.name
    zone.status = payload.status
    db.commit()
    db.refresh(zone)
    return zone


@app.delete("/fence/zones/{zone_id}", status_code=204)
def delete_zone(zone_id: int, db: Session = Depends(get_db)):
    zone = db.query(models.FenceZone).get(zone_id)
    if not zone:
        raise HTTPException(status_code=404, detail="Zone not found")
    db.delete(zone)
    db.commit()


@app.get("/fence/settings", response_model=schemas.FenceSettingsOut)
def get_fence_settings(db: Session = Depends(get_db)):
    return db.query(models.FenceSettings).first()


@app.patch("/fence/settings", response_model=schemas.FenceSettingsOut)
def update_fence_settings(payload: schemas.FenceSettingsUpdate, db: Session = Depends(get_db)):
    settings = db.query(models.FenceSettings).first()
    for k, v in payload.model_dump(exclude_none=True).items():
        setattr(settings, k, v)
    db.commit()
    db.refresh(settings)
    return settings


@app.post("/assistant/chat", response_model=schemas.AssistantChatResponse)
def assistant_chat(payload: schemas.AssistantChatRequest, db: Session = Depends(get_db)):
    msg = payload.message.lower().strip()
    cameras_count = db.query(models.Camera).count()
    online_cameras = db.query(models.Camera).filter(models.Camera.status == "Online").count()
    alerts = db.query(models.Alert).order_by(models.Alert.id.desc()).all()
    alerts_count = len(alerts)
    zones = db.query(models.FenceZone).all()
    zones_count = len(zones)
    elevated_zones = len([z for z in zones if str(getattr(z, "status", "")).lower() == "amber"])

    if any(w in msg for w in ["hello", "hi", "hey"]):
        reply = "Hello Operator. I am IBVAP Assistant, online and ready to help. Ask me about cameras, alerts, or the perimeter fence."
    elif "camera" in msg:
        reply = f"There are {cameras_count} registered camera nodes, {online_cameras} currently online."
    elif "alert" in msg:
        if alerts_count == 0:
            reply = "No alerts have been logged yet. All sectors are quiet."
        else:
            latest = alerts[0]
            reply = f"There are {alerts_count} alerts on record. Most recent: '{latest.title}' ({latest.severity})."
    elif "fence" in msg or "zone" in msg:
        reply = f"The virtual fence has {zones_count} zones configured, {elevated_zones} at elevated status."
    elif "status" in msg or "system" in msg:
        reply = f"System status: {online_cameras}/{cameras_count} cameras online, {alerts_count} alerts logged, {elevated_zones} zones elevated. All systems nominal."
    elif "help" in msg:
        reply = "I can answer questions about cameras, alerts, fence zones, or overall system status. Try asking how many alerts today or fence status."
    elif "thank" in msg:
        reply = "You are welcome, Operator. Stay vigilant."
    else:
        reply = "I am still learning. I can currently help with camera counts, alert summaries, and fence zone status. Try asking about one of those."

    return schemas.AssistantChatResponse(reply=reply)
