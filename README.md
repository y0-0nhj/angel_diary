# 👼 천사일기 (Angel Diary)

**사랑하는 반려동물과의 추억을 기록하고, 무지개다리 너머에서 다시 만날 희망을 간직하는 치유의 일기 앱**

[![Flutter](https://img.shields.io/badge/Developed%20with-Flutter-02569B?logo=flutter)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Language-Dart-0175C2?logo=dart)](https://dart.dev/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## ✨ 프로젝트 소개

'천사일기'는 사랑하는 반려동물을 먼저 떠나보낸 이들이 그들과의 소중한 추억을 기록하고, 슬픔 속에서 위로와 희망을 찾을 수 있도록 돕기 위해 개발된 모바일 앱입니다. 

단순한 기록을 넘어, 반려동물이 무지개다리 너머 '천국의 섬'에서 행복하게 지내기를 소망하며, 언젠가 다시 만날 날을 기약하는 따뜻한 메시지를 담고 있습니다.

## 🌟 주요 기능

### 🎨 천사 캐릭터 생성
- **개성 있는 천사 만들기**: 반려동물의 특징을 반영한 고유한 천사 캐릭터 생성
- **커스터마이징**: 얼굴 타입, 색상, 꼬리 등 다양한 옵션으로 개인화
- **실시간 미리보기**: 생성 과정에서 실시간으로 캐릭터 확인 가능

### 📝 일기 및 추억 기록
- **감정 일기**: 매일의 감정과 생각을 자유롭게 기록
- **추억 보관함**: 사진과 함께 소중한 순간들을 영원히 보관
- **캘린더 연동**: 날짜별로 정리된 추억 관리

### 🎯 목표 설정 및 달성
- **일일 목표**: 작은 목표부터 시작하여 성취감 느끼기
- **진행 상황 추적**: 목표 달성 과정을 시각적으로 확인
- **동기부여 메시지**: 천사가 보내는 격려와 응원

### 🙏 감사 표현
- **감사 일기**: 매일 감사한 일들을 기록하며 긍정적 마인드 유지
- **소중한 순간**: 작은 행복들도 놓치지 않고 기록
- **치유의 과정**: 감사함을 통해 마음의 상처 치유

### 💌 소원 및 편지
- **천사에게 편지**: 무지개다리 너머의 반려동물에게 마음을 전달
- **소원 빌기**: 간절한 마음을 담은 소원을 천사에게 전달
- **위로의 메시지**: 천사가 보내는 따뜻한 위로와 희망

### 🎵 치유의 음악
- **배경음악**: 평온한 마음을 위한 힐링 음악 제공
- **감정별 음악**: 상황에 맞는 음악으로 마음의 안정 찾기

### 🌍 다국어 지원
- **한국어, 영어, 일본어** 지원으로 전 세계 사용자에게 서비스
- **로컬라이제이션**: 각 언어권에 맞는 문화적 배경 고려

## 🚀 개발 배경

개발자는 개인적으로 깊은 시련과 무기력함을 경험했으며, 이 시기를 6마리의 고양이들과 함께하며 이겨냈습니다. 특히 사랑하는 고양이가 두 번의 죽음의 문턱을 넘는 것을 보며, 반려동물의 존재가 주는 큰 위로와, 그들을 떠나보냈을 때의 상실감에 깊이 공감하게 되었습니다.

이러한 경험과 깊은 신앙을 바탕으로, 같은 아픔을 겪는 이들에게 위로와 희망을 전하고 싶다는 사명을 품고 기술을 통해 이 소명을 실현하고자 Flutter를 활용하여 '천사일기'를 개발하기 시작했습니다.

## 🛠️ 기술 스택

### Frontend
- **Flutter 3.8.1+** - 크로스 플랫폼 모바일 앱 개발
- **Dart** - 프로그래밍 언어
- **Material Design** - UI/UX 디자인 시스템

### Backend & Services
- **Supabase** - 인증 및 데이터베이스
- **Firebase** - 푸시 알림 및 분석
- **Kakao SDK** - 소셜 로그인

### 주요 패키지
- `table_calendar` - 캘린더 UI
- `audioplayers` - 음악 재생
- `image_picker` - 이미지 선택
- `flutter_local_notifications` - 로컬 알림
- `shared_preferences` - 로컬 데이터 저장
- `flutter_dotenv` - 환경변수 관리
- `http` - HTTP 통신
- `webview_flutter` - 웹뷰

### 개발 도구
- **Cursor AI** - AI 코드 어시스턴트
- **Gemini** - AI 개발 지원

## 📱 지원 플랫폼

- ✅ **Android** (API 21+)
- ✅ **iOS** (iOS 11.0+)
- ✅ **Web** (Chrome, Safari, Firefox)
- ✅ **Windows** (Windows 10+)
- ✅ **macOS** (macOS 10.14+)
- ✅ **Linux** (Ubuntu 18.04+)

## 🚀 설치 및 실행

### 사전 요구사항
- Flutter SDK 3.8.1 이상
- Dart SDK 3.0.0 이상
- Android Studio / VS Code
- Git

### 설치 방법

1. **저장소 클론**
```bash
git clone https://github.com/your-username/angel_diary.git
cd angel_diary
```

2. **의존성 설치**
```bash
flutter pub get
```

3. **환경 설정**
```bash
# .env 파일 생성 (선택사항)
cp .env.example .env
# 필요한 환경변수 설정
```

4. **앱 실행**
```bash
# 디버그 모드로 실행
flutter run

# 특정 플랫폼에서 실행
flutter run -d android
flutter run -d ios
flutter run -d web
```

### 빌드 방법

```bash
# Android APK 빌드
flutter build apk --release

# iOS 빌드 (macOS에서만)
flutter build ios --release

# Web 빌드
flutter build web --release
```

## 📁 프로젝트 구조

```
lib/
├── main.dart                 # 앱 진입점
├── home.dart                 # 홈 화면
├── character_view.dart       # 천사 캐릭터 뷰
├── models/                   # 데이터 모델
│   ├── angel_data.dart
│   └── wish.dart
├── features/                 # 기능별 모듈
│   ├── angel/               # 천사 관련 기능
│   ├── calendar/            # 캘린더 기능
│   ├── diary/               # 일기 기능
│   ├── goals/               # 목표 기능
│   ├── wishes/              # 소원 기능
│   └── home/                # 홈 화면 기능
├── screens/                  # 화면 구성
│   ├── auth/                # 인증 관련 화면
│   ├── help/                # 도움말 화면
│   └── home/                # 홈 화면
├── services/                 # 서비스 레이어
│   ├── auth/                # 인증 서비스
│   ├── wish_service.dart
│   └── ...
├── managers/                 # 데이터 관리자
│   ├── angel_data_manager.dart
│   ├── calendar_data_manager.dart
│   └── ...
├── widgets/                  # 재사용 가능한 위젯
├── utils/                    # 유틸리티 함수
├── common/                   # 공통 상수 및 설정
└── generated/                # 자동 생성 파일
    └── l10n/                # 다국어 지원
```

## 🎨 디자인 시스템

### 색상 팔레트
- **Primary**: `#737B69` (자연스러운 녹색)
- **Background**: `#F8F5EF` (따뜻한 베이지)
- **Text**: `#3D3D3D` (부드러운 회색)
- **Card**: `#FFFFFF` (순백색)

### 폰트
- **한국어**: Cafe24Oneprettynight
- **영어/기타**: Pretendard, MaruBuri
- **특수 폰트**: 다양한 한글 폰트 지원

## 🌐 다국어 지원

현재 지원 언어:
- 🇰🇷 한국어 (기본)
- 🇺🇸 영어
- 🇯🇵 일본어

새로운 언어 추가는 `lib/l10n/` 디렉토리의 `.arb` 파일을 수정하여 가능합니다.

## 🔧 개발 가이드

### 코드 스타일
- Dart 공식 스타일 가이드 준수
- `flutter_lints` 패키지 사용
- 의미있는 변수명과 함수명 사용

### 커밋 컨벤션
```
feat: 새로운 기능 추가
fix: 버그 수정
docs: 문서 수정
style: 코드 스타일 변경
refactor: 코드 리팩토링
test: 테스트 추가/수정
chore: 빌드 과정 또는 보조 기능 수정
```

### 브랜치 전략
- `main`: 프로덕션 브랜치
- `develop`: 개발 브랜치
- `feature/*`: 기능 개발 브랜치
- `hotfix/*`: 긴급 수정 브랜치

## 🧪 테스트

```bash
# 단위 테스트 실행
flutter test

# 통합 테스트 실행
flutter test integration_test/

# 커버리지 확인
flutter test --coverage
```

## 📊 성능 최적화

- **이미지 최적화**: WebP 형식 사용
- **메모리 관리**: 적절한 dispose() 호출
- **빌드 최적화**: const 생성자 활용
- **네트워크 최적화**: HTTP 캐싱 및 압축

## 🔒 보안

- **데이터 암호화**: 민감한 데이터 암호화 저장
- **API 보안**: Supabase RLS 정책 적용
- **환경변수**: 민감한 정보는 환경변수로 관리
- **권한 관리**: 최소 권한 원칙 적용

## 🚀 배포

### Android
1. `android/app/build.gradle.kts`에서 버전 업데이트
2. `flutter build apk --release` 실행
3. Google Play Console에 업로드

### iOS
1. `ios/Runner/Info.plist`에서 버전 업데이트
2. `flutter build ios --release` 실행
3. Xcode에서 Archive 및 App Store Connect 업로드

### Web
1. `flutter build web --release` 실행
2. `build/web/` 폴더를 웹 서버에 배포

## 🤝 기여하기

천사일기 프로젝트에 기여해주셔서 감사합니다!

### 기여 방법
1. 이 저장소를 Fork합니다
2. 새로운 기능 브랜치를 생성합니다 (`git checkout -b feature/amazing-feature`)
3. 변경사항을 커밋합니다 (`git commit -m 'Add some amazing feature'`)
4. 브랜치에 Push합니다 (`git push origin feature/amazing-feature`)
5. Pull Request를 생성합니다

### 버그 리포트
버그를 발견하셨다면 [Issues](https://github.com/your-username/angel_diary/issues)에 상세한 정보와 함께 리포트해주세요.

### 기능 제안
새로운 기능 아이디어가 있으시다면 [Discussions](https://github.com/your-username/angel_diary/discussions)에서 논의해주세요.

## 📝 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다. 자세한 내용은 [LICENSE](LICENSE) 파일을 참조하세요.

## 🙏 감사의 말

- **Flutter 팀**: 훌륭한 프레임워크 제공
- **Supabase 팀**: 강력한 백엔드 서비스
- **오픈소스 커뮤니티**: 다양한 패키지와 도구 제공
- **사용자들**: 소중한 피드백과 지원

## 📞 연락처

- **개발자**: 윤혜지 (Yoon Hyeji)
- **이메일**: [your.email@example.com](mailto:your.email@example.com)
- **GitHub**: [@your-username](https://github.com/your-username)

---

**천사일기와 함께 소중한 추억을 간직하고, 마음의 치유를 경험해보세요. 💕**