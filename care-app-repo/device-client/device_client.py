"""
학교컴(메인컴)에서 돌리는 클라이언트 예제.
- 학교측에서 포트를 열 필요 없음: 이 스크립트가 서버로 나가는(outbound) 연결만 맺음.
- WebSocket 으로 서버에 상시 연결 → 서버가 명령(라이브 요청 등)을 내리면 받아서 처리.
- 주기적으로 생활상태/이벤트를 REST POST 로 서버에 밀어넣음.
- 낙상 판정(로봇 청소기 카메라 영상 분석) 결과가 나오면 POST /api/fall/trigger.

실행: pip install websockets requests opencv-python
     python device_client.py
"""
import asyncio
import base64
import time
import cv2
import requests
import websockets

SERVER = "http://서버IP:8000"          # 배포한 서버 주소 (http 또는 https)
WS_SERVER = SERVER.replace("http", "ws") + "/ws/device"
DEVICE_LOCATION = "거실"

cap = cv2.VideoCapture(0)  # 로봇 청소기 카메라(또는 연결된 캠)


def capture_snapshot_jpeg() -> str:
    ok, frame = cap.read()
    if not ok:
        return ""
    ok, buf = cv2.imencode(".jpg", frame, [cv2.IMWRITE_JPEG_QUALITY, 60])
    b64 = base64.b64encode(buf.tobytes()).decode()
    return f"data:image/jpeg;base64,{b64}"


async def state_loop():
    """주기적으로 현재 상태를 서버에 밀어넣음 (예: 10초마다)."""
    while True:
        try:
            # TODO: 여기에 영상/음성 연산 결과로 life(active/sleeping/away/resting) 판정
            life = "active"
            requests.post(f"{SERVER}/api/device/state",
                          json={"life": life, "location": DEVICE_LOCATION}, timeout=5)
        except Exception as e:
            print("state push fail:", e)
        await asyncio.sleep(10)


async def ws_loop():
    """서버와 상시 연결 유지. 명령 수신 시 처리."""
    while True:
        try:
            async with websockets.connect(WS_SERVER) as ws:
                print("서버에 연결됨 (포트개방 불필요)")
                async for msg in ws:
                    import json
                    m = json.loads(msg)
                    if m.get("type") == "request_live":
                        # 보호자 앱이 라이브 요청 → 스냅샷 한 장 찍어 서버로 업로드
                        img = capture_snapshot_jpeg()
                        if img:
                            requests.post(f"{SERVER}/api/device/snapshot",
                                          json={"image": img}, timeout=10)
        except Exception as e:
            print("ws 끊김, 5초 후 재접속:", e)
            await asyncio.sleep(5)


def on_fall_detected():
    """영상 분석으로 낙상 판정 시 호출 → 앱에 즉시 알림."""
    try:
        requests.post(f"{SERVER}/api/fall/trigger", timeout=5)
    except Exception:
        pass


async def main():
    await asyncio.gather(ws_loop(), state_loop())


if __name__ == "__main__":
    asyncio.run(main())
