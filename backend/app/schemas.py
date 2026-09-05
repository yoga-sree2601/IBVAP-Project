from typing import Optional
from pydantic import BaseModel


class CameraBase(BaseModel):
    name: str
    sector: str
    ip: str
    rtsp: str = ""
    type: str = "Fixed IP"
    status: str = "Online"
    img: str = ""
    night: bool = False


class CameraCreate(CameraBase):
    pass


class CameraOut(CameraBase):
    id: int

    class Config:
        from_attributes = True


class AlertBase(BaseModel):
    severity: str
    title: str
    description: str = ""


class AlertCreate(AlertBase):
    pass


class AlertOut(AlertBase):
    id: int
    ref_code: str
    timestamp: str

    class Config:
        from_attributes = True


class FenceZoneBase(BaseModel):
    name: str
    status: str = "teal"


class FenceZoneCreate(FenceZoneBase):
    pass


class FenceZoneOut(FenceZoneBase):
    id: int

    class Config:
        from_attributes = True


class FenceSettingsUpdate(BaseModel):
    sensitivity: Optional[int] = None
    human_detection: Optional[bool] = None
    animal_filter: Optional[bool] = None
    directional_alert: Optional[bool] = None
    armed: Optional[bool] = None


class FenceSettingsOut(BaseModel):
    sensitivity: int
    human_detection: bool
    animal_filter: bool
    directional_alert: bool
    armed: bool

    class Config:
        from_attributes = True


class LoginRequest(BaseModel):
    operator_id: str
    passcode: str


class LoginResponse(BaseModel):
    ok: bool
    operator_id: str
    token: str

class AssistantChatRequest(BaseModel):
    message: str


class AssistantChatResponse(BaseModel):
    reply: str

class AssistantChatRequest(BaseModel):
    message: str


class AssistantChatResponse(BaseModel):
    reply: str
