"""에러코드 정의. 앱(AppError)과 서버가 같은 코드 문자열을 사용합니다."""


class ErrorCode:
    CONNECTION_LOST = "CONNECTION_LOST"
    INVALID_LIFE = "INVALID_LIFE"
    DEVICE_NOT_CONNECTED = "DEVICE_NOT_CONNECTED"
    INTERNAL = "INTERNAL_ERROR"


ERROR_MESSAGES = {
    ErrorCode.CONNECTION_LOST: "메인 컴퓨터와 연결이 끊겼어요. 영상과 알림이 늦어질 수 있습니다.",
    ErrorCode.INVALID_LIFE: "잘못된 life 값입니다 (active/sleeping/away/resting 중 하나).",
    ErrorCode.DEVICE_NOT_CONNECTED: "메인 컴퓨터가 서버에 연결되어 있지 않아요.",
    ErrorCode.INTERNAL: "서버 내부 오류가 발생했어요.",
}


def app_error(code: str) -> dict:
    """앱의 AppError 형태와 동일한 {"code", "message"} 딕셔너리 반환."""
    return {"code": code, "message": ERROR_MESSAGES.get(code, code)}
