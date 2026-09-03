from sqlalchemy import Column, Integer, String, Boolean
from .database import Base


class Camera(Base):
    __tablename__ = "cameras"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    sector = Column(String, nullable=False)
    ip = Column(String, nullable=False)
    rtsp = Column(String, default="")
    type = Column(String, default="Fixed IP")  # Fixed IP | PTZ | Thermal | Dome
    status = Column(String, default="Online")  # Online | Offline
    img = Column(String, default="")
    night = Column(Boolean, default=False)


class Alert(Base):
    __tablename__ = "alerts"

    id = Column(Integer, primary_key=True, index=True)
    ref_code = Column(String, nullable=False)
    severity = Column(String, nullable=False)  # critical | warning | info
    title = Column(String, nullable=False)
    description = Column(String, default="")
    timestamp = Column(String, default="")


class FenceZone(Base):
    __tablename__ = "fence_zones"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    status = Column(String, default="teal")  # teal (normal) | amber (elevated)


class FenceSettings(Base):
    __tablename__ = "fence_settings"

    id = Column(Integer, primary_key=True, index=True)
    sensitivity = Column(Integer, default=3)  # 1 low, 2 medium, 3 high
    human_detection = Column(Boolean, default=True)
    animal_filter = Column(Boolean, default=True)
    directional_alert = Column(Boolean, default=False)
    armed = Column(Boolean, default=False)
