import 'care_service.dart';
import 'mock_care_service.dart';
import 'api_care_service.dart';

/// 실서버 배포 시: useMock = false, kServerUrl 을 본인 서버 주소로.
/// (앱 설정 화면에서도 서버 주소를 런타임에 바꿀 수 있음)
/// - 안드로이드 에뮬레이터에서 개발 PC 서버: http://10.0.2.2:8000
/// - 같은 공유기 안 실폰 → 개발 PC: http://<PC의 LAN IP>:8000
/// - 실서버: http(s)://your-domain-or-ip[:port]
const bool useMock = false; // ApiCareService 가 기본. 서버주소가 비어있으면 자동으로 데모(목업) 모드
const String kServerUrl = ''; // '' 이면 데모 모드로 시작. 실서버 주소를 넣으면 바로 서버 모드.

final CareService careService = useMock
    ? MockCareService()
    : ApiCareService(baseUrl: kServerUrl);
