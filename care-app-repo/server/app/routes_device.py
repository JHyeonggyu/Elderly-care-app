"""메인컴(학교컴) 및 데모용 엔드포인트."""
import asyncio

from fastapi import APIRouter

from . import state
from .errors import ErrorCode
from .models import DeviceEvent, DeviceState, SnapshotReq

router = APIRouter()


async def _fall_countdown():
    for i in range(15, 0, -1):
        async with state.LOCK:
            state.STATE["countdown"] = i
        await asyncio.sleep(1)
    async with state.LOCK:
        state.STATE["noResponse"] = True
        state.STATE["countdown"] = 0
        state.STATE["events"].insert(0, {"time": state.now_hm(), "text": "로봇 확인 응답 없음", "color": state.RED})


@router.post("/device/state")
async def device_state(d: DeviceState):
    """메인컴이 생활상태 판정 결과를 푸시."""
    if d.life not in state.LIFE_LABEL:
        return {"ok": False, "error": ErrorCode.INVALID_LIFE}
    await state.set_life(d.life, d.location)
    return {"ok": True}


@router.post("/device/event")
async def device_event(e: DeviceEvent):
    """메인컴이 임의 이벤트(기상, 외출 등)를 푸시."""
    await state.log_event(e.text, e.color)
    return {"ok": True}


@router.post("/device/snapshot")
async def device_snapshot(r: SnapshotReq):
    """메인컴이 라이브 요청에 대한 응답으로 스냅샷 업로드."""
    state.latest_snapshot = r.image
    return {"ok": True}


@router.post("/fall/trigger")
async def trigger_fall():
    """메인컴이 낙상 감지 시 호출 (또는 데모)."""
    async with state.LOCK:
        if state.STATE["fall"]:
            return {"ok": True, "already": True}
        state.STATE["fall"] = True
        state.STATE["noResponse"] = False
        state.STATE["countdown"] = 15
        state.STATE["location"] = "거실"
        state.STATE["events"].insert(0, {"time": state.now_hm(), "text": "낙상 감지 · 거실", "color": state.RED})
    if state.fall_task:
        state.fall_task.cancel()
    state.fall_task = asyncio.create_task(_fall_countdown())
    return {"ok": True}


@router.post("/tv-sound")
async def tv_sound():
    """메인컴이 무시 가능한 소리(TV) 감지 시 호출."""
    async with state.LOCK:
        state.STATE["soundTag"] = "TV 소리 · 무시됨"

    async def _clear():
        await asyncio.sleep(4)
        async with state.LOCK:
            state.STATE["soundTag"] = None

    asyncio.create_task(_clear())
    return {"ok": True}


@router.post("/disconnect")
async def simulate_disconnect():
    """연결 끊김 시뮬레이션 (데모)."""
    state.set_connection_lost()
    return {"ok": True}
