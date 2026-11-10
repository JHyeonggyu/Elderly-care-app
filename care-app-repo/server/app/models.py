"""요청/응답 Pydantic 모델."""
from typing import Optional

from pydantic import BaseModel


class SettingsPatch(BaseModel):
    skeletonOnly: Optional[bool] = None
    listening: Optional[bool] = None
    sleepAt: Optional[str] = None
    wakeAt: Optional[str] = None
    sensitivity: Optional[float] = None


class AwayReq(BaseModel):
    on: bool


class DeviceState(BaseModel):
    life: str  # active|sleeping|away|resting
    location: str


class DeviceEvent(BaseModel):
    text: str
    color: int = 0xFF008080


class SnapshotReq(BaseModel):
    image: str  # data URL (data:image/jpeg;base64,...)
