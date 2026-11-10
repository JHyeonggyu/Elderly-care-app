/// 앱 전역 오류 표현. 서버 연결 후 HTTP/소켓 오류를 이 형태로 변환해서 사용.
class AppError {
  final String code;
  final String message;
  const AppError(this.code, this.message);

  static const connectionLost = AppError('CONNECTION_LOST', '메인 컴퓨터와 연결이 끊겼어요. 영상과 알림이 늦어질 수 있습니다.');
}
