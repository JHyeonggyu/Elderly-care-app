# API 명세서

Base URL: `http(s)://서버주소:8000`

## 공통

- 모든 응답은 JSON.
- `life` 값: `active`(활동) / `sleeping`(수면) / `away`(외출) / `resting`(휴식)
- `color` 는 `0xAARRGGBB` 정수.
- 에러 응답 형태: `{"code": "...", "message": "..."}` (에러코드는 README 참고)

---

## A. 보호자 앱용 (routes_app.py)

| 메서드 | 경로 | 설명 | 요청 바디 |
|---|---|---|---|
| GET | `/api/state` | 전체 상태 조회 (앱이 2초마다 폴링) | — |
| PATCH | `/api/settings` | 설정 변경 | `{skeletonOnly?, listening?, sleepAt?, wakeAt?, sensitivity?}` |
| POST | `/api/away` | 외출 모드 토글 | `{"on": true\|false}` |
| POST | `/api/fall/resolve` | 낙상 해제 (보호자 확인) | — |
| POST | `/api/reconnect` | 오류 배너 해제 후 재연결 | — |
| POST | `/api/app/request-live` | 라이브 스냅샷 요청 (메인컴에 전달) | — |
| GET | `/api/snapshot/latest` | 최신 스냅샷 (data URL) 조회 | — |
| GET | `/api/device/status` | 메인컴 연결 여부 | — → `{"connected": bool}` |
| GET | `/api/healthz` | 헬스체크 | — → `{"ok": true}` |

### GET /api/state 응답 예시
```json
{
  "life": "active", "location": "거실", "since": "2026-11-05T08:12:00",
  "fall": false, "noResponse": false, "countdown": 0, "soundTag": null,
  "events": [{"time": "08:12", "text": "기상 · 활동 시작", "color": 4278222464}],
  "skeletonOnly": false, "listening": false,
  "sleepAt": "22:30", "wakeAt": "06:30", "sensitivity": 0.6,
  "error": null
}
```

---

## B. 메인컴(학교컴)/데모용 (routes_device.py)

| 메서드 | 경로 | 설명 | 요청 바디 |
|---|---|---|---|
| POST | `/api/device/state` | 생활상태 판정 결과 푸시 | `{"life": "active", "location": "거실"}` |
| POST | `/api/device/event` | 임의 이벤트 푸시 | `{"text": "기상", "color": 4278222464}` |
| POST | `/api/device/snapshot` | 라이브 요청 응답 스냅샷 업로드 | `{"image": "data:image/jpeg;base64,..."}` |
| POST | `/api/fall/trigger` | 낙상 감지 (15초 카운트다운 시작) | — |
| POST | `/api/tv-sound` | 무시 가능 소리(TV) 감지 (4초 표시) | — |
| POST | `/api/disconnect` | 연결 끊김 시뮬레이션 (데모) | — |

---

## C. WebSocket (routes_ws.py)

- **접속**: `ws://서버주소:8000/ws/device` (메인컴이 아웃바운드로 연결 유지)
- **서버→메인컴**: `{"type": "request_live"}` (앱이 라이브 요청 시)
- **메인컴→서버**: `{"type": "snapshot", "image": "<data URL>"}`

---

## cURL 데모
```bash
# 낙상 알림 트리거
curl -X POST http://서버IP:8000/api/fall/trigger
# 연결 끊김 시뮬레이션
curl -X POST http://서버IP:8000/api/disconnect
# 메인컴 상태 푸시
curl -X POST http://서버IP:8000/api/device/state -H "Content-Type: application/json" -d '{"life":"sleeping","location":"안방"}'
```
