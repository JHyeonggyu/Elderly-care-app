"""FastAPI 앱 진입점. 라우터를 조립하고 CORS를 설정한다."""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .routes_app import router as app_router
from .routes_device import router as device_router
from .routes_ws import router as ws_router

app = FastAPI(title="care-app-server", version="1.0.0")

# 실서버에서는 allow_origins 에 실제 도메인만 넣을 것. 앱(APK)은 CORS 무관.
app.add_middleware(
    CORSMiddleware, allow_origins=["*"], allow_methods=["*"], allow_headers=["*"]
)

# /api 접두어 라우터 (REST)
app.include_router(app_router, prefix="/api")
app.include_router(device_router, prefix="/api")
# WebSocket (접두어 없이 /ws/device)
app.include_router(ws_router)
