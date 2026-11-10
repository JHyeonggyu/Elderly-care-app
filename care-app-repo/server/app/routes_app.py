"""보호자 앱(phone)이 호출하는 엔드포인트."""
import asyncio

from fastapi import APIRouter

from . import state
from .errors import ErrorCode, app_error
from .models import AwayReq, SettingsPatch

router = APIRouter()


@router.get("/state")
async def get_state():
    async with state.LOCK:
        return dict(state.STATE)


@router.patch("/settings")
async def patch_settings(p: SettingsPatch):
    async with state.LOCK:
        if p.skeletonOnly is not None:
            state.STATE["skeletonOnly"] = p.skeletonOnly
        if p.listening is not None:
            state.STATE["listening"] = p.listening
        if p.sleepAt is not None:
            state.STATE["sleepAt"] = p.sleepAt
        if p.wakeAt is not None:
            state.STATE["wakeAt"] = p.wakeAt
        if p.sensitivity is not None:
            state.STATE["sensitivity"] = max(0.0, min(1.0, p.sensitivity))
    return {"ok": True}


@router.post("/away")
async def post_away(r: AwayReq):
    life = "away" if r.on else "active"
    loc = "현관" if r.on else "거실"
    await state.set_life(life, loc)
    return {"ok": True}


@router.post("/fall/resolve")
async def resolve_fall():
    if state.fall_task:
        state.fall_task.cancel()
        state.fall_task = None
    async with state.LOCK:
        state.STATE["fall"] = False
        state.STATE["noResponse"] = False
        state.STATE["countdown"] = 0
        state.STATE["events"].insert(0, {"time": state.now_hm(), "text": "보호자 확인 완료", "color": state.TEAL})
    return {"ok": True}


@router.post("/reconnect")
async def reconnect():
    state.clear_error()
    return {"ok": True}


@router.post("/app/request-live")
async def request_live():
    """앱이 라이브 스냅샷 요청 → WebSocket 으로 연결된 메인컴에 전달."""
    if state.device_ws is None:
        return {"ok": False, "error": app_error(ErrorCode.DEVICE_NOT_CONNECTED)}
    await state.device_ws.send_json({"type": "request_live"})
    return {"ok": True}


@router.get("/snapshot/latest")
async def snapshot_latest():
    return {"image": state.latest_snapshot}


@router.get("/device/status")
async def device_status():
    return {"connected": state.device_ws is not None}


@router.get("/healthz")
async def healthz():
    return {"ok": True}
