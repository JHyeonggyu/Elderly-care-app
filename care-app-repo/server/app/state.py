"""인메모리 상태 저장소 + 헬퍼. (실서버에서는 Redis/DB로 교체 권장)"""
import asyncio
from datetime import datetime
from typing import Optional

from fastapi import WebSocket

from .errors import ErrorCode, app_error

# ---------- 공유 상태 ----------
STATE = {
    "life": "active",
    "location": "거실",
    "since": datetime.now().isoformat(timespec="seconds"),
    "fall": False,
    "noResponse": False,
    "countdown": 0,
    "soundTag": None,
    "events": [
        {"time": "08:12", "text": "기상 · 활동 시작", "color": 0xFF008080},
        {"time": "09:40", "text": "외출 · 귀가 완료", "color": 0xFF4A90D9},
        {"time": "11:42", "text": "소파에서 휴식", "color": 0xFFFFB300},
    ],
    "skeletonOnly": False,
    "listening": False,
    "sleepAt": "22:30",
    "wakeAt": "06:30",
    "sensitivity": 0.6,
    "error": None,
}
LOCK = asyncio.Lock()

# 낙상 카운트다운 태스크
fall_task: Optional[asyncio.Task] = None

# WebSocket 으로 연결된 메인컴(학교컴) + 최신 스냅샷
device_ws: Optional[WebSocket] = None
latest_snapshot: Optional[str] = None

# ---------- 상수 ----------
LIFE_LABEL = {"active": "활동 중", "sleeping": "수면 중", "away": "외출 중", "resting": "휴식 중"}
LIFE_COLOR = {"active": 0xFF008080, "sleeping": 0xFF3F51B5, "away": 0xFF4A90D9, "resting": 0xFFFFB300}
RED = 0xFFE53935
TEAL = 0xFF008080


def now_hm() -> str:
    return datetime.now().strftime("%H:%M")


async def log_event(text: str, color: int):
    """이벤트를 최신순으로 STATE.events 에 추가."""
    async with LOCK:
        STATE["events"].insert(0, {"time": now_hm(), "text": text, "color": color})


async def set_life(life: str, location: str):
    async with LOCK:
        STATE["life"] = life
        STATE["location"] = location
        STATE["since"] = datetime.now().isoformat(timespec="seconds")
        STATE["events"].insert(0, {
            "time": now_hm(),
            "text": f"{LIFE_LABEL[life]} · {location}",
            "color": LIFE_COLOR[life],
        })


def set_connection_lost():
    STATE["error"] = app_error(ErrorCode.CONNECTION_LOST)


def clear_error():
    STATE["error"] = None
