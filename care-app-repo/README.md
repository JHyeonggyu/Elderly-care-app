# 어르신 케어 앱 (care-app)

> 로봇 청소기 카메라/마이크 → 학교컴(메인컴) 영상분석 → 클라우드 서버 중계 → 보호자 앱
> 학교컴에서 **포트 개방 없이** 아웃바운드 연결만으로 데이터를 주고받습니다.

![architecture](https://img.shields.io/badge/arch-robot%20%E2%86%92%20mainpc%20%E2%86%92%20cloud%20%E2%86%92%20app-blue)
![flutter](https://img.shields.io/badge/app-Flutter%203.47-blue)
![server](https://img.shields.io/badge/server-FastAPI%20%2B%20Docker-green)
![license](https://img.shields.io/badge/license-MIT-lightgrey)

---

## 시스템 구성도

```
┌─────────────────┐   USB/WiFi(동일공간)   ┌──────────────────────┐
│ 로봇 청소기      │ ─────────────────────▶ │ 학교컴 (메인컴)        │
│ (카메라/마이크)  │                        │ · 영상/음성 연산        │
└─────────────────┘                        │ · 낙상 판정            │
                                           └─────────┬────────────┘
                                                     │ 아웃바운드만 (포트개방 불필요)
                                                     │ REST POST + WebSocket(:8000)
                                                     ▼
                                           ┌──────────────────────┐
                                           │ 클라우드 호스팅 서버    │
                                           │ (FastAPI + Docker)    │
                                           │  · 상태/이벤트 중계     │
                                           │  · WebSocket 명령 전달  │
                                           └─────────┬────────────┘
                                                     │ HTTPS/REST 폴링
                                                     ▼
                                           ┌──────────────────────┐
                                           │ 보호자 폰 (Android APK)│
                                           │  · 홈/실시간/기록/설정  │
                                           │  · 낙상 전체화면 알림   │
                                           └──────────────────────┘
```

---

## 빠른 시작 (3단계)

### 1단계: 호스팅 서버 띄우기 (클라우드)
```bash
cd server
docker compose up -d --build
# → http://서버IP:8000  (확인: http://서버IP:8000/api/healthz)
# 방화벽/보안그룹에서 8000 포트 오픈 필수
```

### 2단계: 학교컴(메인컴)에서 클라이언트 실행
```bash
cd device-client
pip install -r requirements.txt
# device_client.py 안의 SERVER 변수를 본인 서버 주소로 수정
python device_client.py
```
→ 학교컴이 서버에 WebSocket으로 상시 연결됩니다. 포트 개방은 필요 없습니다.

### 3단계: 앱 설치 및 연결
- `dist/care_app-release.apk` 를 폰에 설치 (설정 → 서버 주소에 `http://서버IP:8000` 입력)
- 서버 주소를 비워두면 **데모 모드**로 바로 동작합니다.

---

## 폴더 구조

```
care-app/
├── README.md                     # 이 파일
├── server/                       # ★ 호스팅 서버 (클라우드에서 실행)
│   ├── app/
│   │   ├── main.py               # 진입점, 라우터 조립, CORS
│   │   ├── errors.py             # 에러코드 정의 (앱과 공유)
│   │   ├── models.py             # 요청/응답 Pydantic 모델
│   │   ├── state.py              # 인메모리 상태 저장소 + 헬퍼
│   │   ├── routes_app.py         # 보호자 앱용 REST 엔드포인트
│   │   ├── routes_device.py      # 메인컴/데모용 REST 엔드포인트
│   │   └── routes_ws.py          # WebSocket /ws/device (메인컴 상시연결)
│   ├── requirements.txt
│   ├── Dockerfile
│   └── docker-compose.yml
├── device-client/                # 학교컴(메인컴)에서 실행
│   ├── device_client.py          # WebSocket 상시연결 + 상태푸시 + 스냅샷
│   └── requirements.txt
├── app/                          # Flutter 앱 소스 (Android)
│   ├── lib/
│   │   ├── data/services/
│   │   │   ├── care_service.dart       # 추상 인터페이스
│   │   │   ├── api_care_service.dart   # 실서버 연결 (데모모드 겸용)
│   │   │   ├── mock_care_service.dart  # 목업
│   │   │   └── service_locator.dart    # 전역 주입 (useMock 플래그)
│   │   └── features/             # 홈/실시간/기록/설정/낙상 화면
│   ├── pubspec.yaml
│   └── android/                  # release 서명 설정 포함
├── dist/                         # 빌드 결과물
│   ├── care_app-release.apk      # release 서명 안드로이드 앱 (17.7MB)
│   └── care_app_web.zip          # 웹 빌드 정적 파일
└── docs/
    └── API.md                    # 상세 API 명세서
```

---

## 에러코드

| code | 메시지 | 발생 시점 |
|---|---|---|
| `CONNECTION_LOST` | 메인 컴퓨터와 연결이 끊겼어요. 영상과 알림이 늦어질 수 있습니다. | 메인컴과 서버 통신 실패 |
| `INVALID_LIFE` | 잘못된 life 값입니다. | `/api/device/state` 에 잘못된 life 전달 |
| `DEVICE_NOT_CONNECTED` | 메인 컴퓨터가 서버에 연결되어 있지 않아요. | 앱이 라이브 요청했으나 메인컴 미접속 |
| `INTERNAL_ERROR` | 서버 내부 오류가 발생했어요. | 기타 서버 오류 |

---

## 앱 빌드 (직접 빌드할 경우)
```bash
cd app
flutter pub get
flutter build apk --release --target-platform android-arm64
# 출력: build/app/outputs/flutter-apk/app-release.apk
```
- release 서명용 키스토어는 `android/app/key.properties` 에 본인 경로/비밀번호를 넣으세요 (예제는 제외됨).
- `service_locator.dart` 의 `kServerUrl` 에 서버 주소를 넣고 빌드하면 앱이 기본으로 서버 모드로 시작합니다.

---

## 주의사항
- 실서버에서는 `server/app/main.py` 의 `allow_origins=["*"]` 를 실제 도메인으로 제한하세요.
- 상태는 인메모리라 서버 재시작 시 초기화됩니다. 영구 저장이 필요하면 `state.py` 를 Redis/DB로 교체하세요.
- 풀(full) 라이브 영상이 필요하면 클라우드에 TURN 서버(coturn)를 띄우고 WebRTC를 사용하세요.

## License
MIT
