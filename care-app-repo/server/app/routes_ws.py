"""메인컴(학교컴)과의 상시 WebSocket 연결. 학교측 포트개방 불필요 (아웃바운드)."""
from fastapi import APIRouter, WebSocket, WebSocketDisconnect

from . import state

router = APIRouter()


@router.websocket("/ws/device")
async def ws_device(ws: WebSocket):
    await ws.accept()
    state.device_ws = ws
    try:
        while True:
            msg = await ws.receive_json()
            # 메인컴이 보내는 이벤트성 메시지 처리
            if msg.get("type") == "snapshot":
                state.latest_snapshot = msg.get("image")
    except WebSocketDisconnect:
        pass
    finally:
        if state.device_ws is ws:
            state.device_ws = None
