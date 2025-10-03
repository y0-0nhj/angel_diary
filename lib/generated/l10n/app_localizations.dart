import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('ko'),
  ];

  /// 앱 제목
  ///
  /// In ko, this message translates to:
  /// **'천사일기'**
  String get appTitle;

  /// 시작하기 버튼 텍스트
  ///
  /// In ko, this message translates to:
  /// **'시작하기'**
  String get startButton;

  /// 스플래시 화면 첫 번째 메시지
  ///
  /// In ko, this message translates to:
  /// **'오늘의 약속 하나,\n너에게 닿는 발걸음 하나,\n세상 가장 따뜻한 약속'**
  String get splashMessage1;

  /// 스플래시 화면 두 번째 메시지
  ///
  /// In ko, this message translates to:
  /// **'가장 먼 미래는, 가장 소중한 지금으로 만들어집니다.\n마음 속 소망을 눈앞의 현실로 만들어드립니다.'**
  String get splashMessage2;

  /// 질문 화면 제목
  ///
  /// In ko, this message translates to:
  /// **'반려동물과 함께 추억을\n 쌓은 적이 있으신가요?'**
  String get questionTitle;

  /// 질문 화면 부제목
  ///
  /// In ko, this message translates to:
  /// **'(강아지, 고양이)'**
  String get questionSubtitle;

  /// 예 버튼
  ///
  /// In ko, this message translates to:
  /// **'예'**
  String get yesButton;

  /// 아니오 버튼
  ///
  /// In ko, this message translates to:
  /// **'아니오'**
  String get noButton;

  /// 천사 등록 제목
  ///
  /// In ko, this message translates to:
  /// **'천사 등록하기'**
  String get angelRegistration;

  /// 이름 입력 라벨
  ///
  /// In ko, this message translates to:
  /// **'당신의 마음 속에 품은 아이의 이름을 입력해주세요.'**
  String get nameInputLabel;

  /// 이름 입력 힌트
  ///
  /// In ko, this message translates to:
  /// **'ex) 행복, 별이'**
  String get nameInputHint;

  /// 펫 타입 라벨
  ///
  /// In ko, this message translates to:
  /// **'아이는 어떤 종류에요?'**
  String get petTypeLabel;

  /// 펫 설명 라벨
  ///
  /// In ko, this message translates to:
  /// **'아이는 어떤 모습이에요?'**
  String get petDescriptionLabel;

  /// 이미지 선택 라벨
  ///
  /// In ko, this message translates to:
  /// **'가장 아름답고 예뻤던 아이의 전신 모습을 선택해주세요.'**
  String get imageSelectionLabel;

  /// 등록 버튼
  ///
  /// In ko, this message translates to:
  /// **'천사 등록하기'**
  String get registerButton;

  /// 아니오 폼 제목
  ///
  /// In ko, this message translates to:
  /// **'괜찮아요.'**
  String get noFormTitle;

  /// 아니오 폼 메시지
  ///
  /// In ko, this message translates to:
  /// **'우리에게는 새로운 시작이 있으니까요.\n당신의 마음속에 작은 씨앗을 심어볼까요? 당신의 천사와 함께 하게 될거에요.'**
  String get noFormMessage;

  /// 씨앗 심기 버튼
  ///
  /// In ko, this message translates to:
  /// **'마음의 씨앗 심기'**
  String get plantSeedButton;

  /// 축하 메시지
  ///
  /// In ko, this message translates to:
  /// **'congratulations!'**
  String get congratulations;

  /// 보관하기 메시지
  ///
  /// In ko, this message translates to:
  /// **'당신만의\n소중한 천사를 만났어요!\n이 모습, 잃어버리지 않도록 하늘의\n정원에 영원히 보관해 드릴까요?'**
  String get storageMessage;

  /// 보관하기 버튼
  ///
  /// In ko, this message translates to:
  /// **'보관하기'**
  String get saveButton;

  /// 나중에 보관하기 버튼
  ///
  /// In ko, this message translates to:
  /// **'나중에 보관하기'**
  String get saveLaterButton;

  /// 나중에 보관하기 경고
  ///
  /// In ko, this message translates to:
  /// **'(유실될 수 있어요)'**
  String get saveLaterWarning;

  /// 로그인 제목
  ///
  /// In ko, this message translates to:
  /// **'로그인'**
  String get loginTitle;

  /// 카카오톡 로그인 버튼
  ///
  /// In ko, this message translates to:
  /// **'카카오톡으로 로그인'**
  String get kakaoLogin;

  /// 네이버 로그인 버튼
  ///
  /// In ko, this message translates to:
  /// **'네이버로 로그인'**
  String get naverLogin;

  /// 구글 로그인 버튼
  ///
  /// In ko, this message translates to:
  /// **'구글로 로그인'**
  String get googleLogin;

  /// 이메일 로그인 버튼
  ///
  /// In ko, this message translates to:
  /// **'이메일로 로그인'**
  String get emailLogin;

  /// 또는 텍스트
  ///
  /// In ko, this message translates to:
  /// **'또는'**
  String get orText;

  /// 회원가입 링크
  ///
  /// In ko, this message translates to:
  /// **'회원가입'**
  String get signUp;

  /// 계정 찾기 링크
  ///
  /// In ko, this message translates to:
  /// **'아이디 또는 비밀번호찾기'**
  String get findAccount;

  /// 언어 선택 제목
  ///
  /// In ko, this message translates to:
  /// **'언어 선택'**
  String get languageSelection;

  /// 한국어
  ///
  /// In ko, this message translates to:
  /// **'한국어'**
  String get korean;

  /// 영어
  ///
  /// In ko, this message translates to:
  /// **'English'**
  String get english;

  /// 일본어
  ///
  /// In ko, this message translates to:
  /// **'日本語'**
  String get japanese;

  /// 설정
  ///
  /// In ko, this message translates to:
  /// **'설정'**
  String get settings;

  /// 음악 설정
  ///
  /// In ko, this message translates to:
  /// **'음악 설정'**
  String get musicSettings;

  /// 알림 설정
  ///
  /// In ko, this message translates to:
  /// **'알림 설정'**
  String get notificationSettings;

  /// 테마 설정
  ///
  /// In ko, this message translates to:
  /// **'테마 설정'**
  String get themeSettings;

  /// 도움말
  ///
  /// In ko, this message translates to:
  /// **'도움말'**
  String get help;

  /// 마이페이지
  ///
  /// In ko, this message translates to:
  /// **'마이페이지'**
  String get myPage;

  /// 천사 정보
  ///
  /// In ko, this message translates to:
  /// **'천사 정보'**
  String get angelInfo;

  /// 일기 기록
  ///
  /// In ko, this message translates to:
  /// **'일기 기록'**
  String get diaryHistory;

  /// 데이터 백업
  ///
  /// In ko, this message translates to:
  /// **'데이터 백업'**
  String get dataBackup;

  /// 앱 정보
  ///
  /// In ko, this message translates to:
  /// **'앱 정보'**
  String get appInfo;

  /// 소망 탭 제목
  ///
  /// In ko, this message translates to:
  /// **'소망'**
  String get wishesTab;

  /// 목표 탭 제목
  ///
  /// In ko, this message translates to:
  /// **'목표'**
  String get goalsTab;

  /// 감사 탭 제목
  ///
  /// In ko, this message translates to:
  /// **'감사'**
  String get gratitudeTab;

  /// 일기 쓰기 버튼
  ///
  /// In ko, this message translates to:
  /// **'오늘의 일기 쓰기'**
  String get writeDiary;

  /// 일기 수정 버튼
  ///
  /// In ko, this message translates to:
  /// **'오늘의 일기 수정'**
  String get editDiary;

  /// 천사 인사말
  ///
  /// In ko, this message translates to:
  /// **'{angelName}와(과) 함께하는 따뜻한 하루가 되길 바라요.'**
  String angelGreeting(String angelName);

  /// 기본 인사말
  ///
  /// In ko, this message translates to:
  /// **'당신의 마음속 사랑은\n시간과 공간을 넘어 전해진다.'**
  String get defaultGreeting;

  /// 일요일
  ///
  /// In ko, this message translates to:
  /// **'일요일'**
  String get sunday;

  /// 월요일
  ///
  /// In ko, this message translates to:
  /// **'월요일'**
  String get monday;

  /// 화요일
  ///
  /// In ko, this message translates to:
  /// **'화요일'**
  String get tuesday;

  /// 수요일
  ///
  /// In ko, this message translates to:
  /// **'수요일'**
  String get wednesday;

  /// 목요일
  ///
  /// In ko, this message translates to:
  /// **'목요일'**
  String get thursday;

  /// 금요일
  ///
  /// In ko, this message translates to:
  /// **'금요일'**
  String get friday;

  /// 토요일
  ///
  /// In ko, this message translates to:
  /// **'토요일'**
  String get saturday;

  /// 격려 메시지 1
  ///
  /// In ko, this message translates to:
  /// **'하나님이 너와 함께 하시니라'**
  String get inspirationalMessage1;

  /// 격려 메시지 2
  ///
  /// In ko, this message translates to:
  /// **'내가 너를 위하여 정한 계획은 평안이요 재앙이 아니니라'**
  String get inspirationalMessage2;

  /// 격려 메시지 3
  ///
  /// In ko, this message translates to:
  /// **'여호와는 나의 목자시니 내게 부족함이 없으리로다'**
  String get inspirationalMessage3;

  /// 격려 메시지 4
  ///
  /// In ko, this message translates to:
  /// **'모든 일이 합력하여 선을 이룬다'**
  String get inspirationalMessage4;

  /// 출처 1
  ///
  /// In ko, this message translates to:
  /// **'창세기 28:15'**
  String get source1;

  /// 출처 2
  ///
  /// In ko, this message translates to:
  /// **'예레미야 29:11'**
  String get source2;

  /// 출처 3
  ///
  /// In ko, this message translates to:
  /// **'시편 23:1'**
  String get source3;

  /// 출처 4
  ///
  /// In ko, this message translates to:
  /// **'로마서 8:28'**
  String get source4;

  /// 격려 메시지 1
  ///
  /// In ko, this message translates to:
  /// **'정말 잘하고 있어요! 💪'**
  String get encouragement1;

  /// 격려 메시지 2
  ///
  /// In ko, this message translates to:
  /// **'훌륭해요! 계속 이렇게 해요! ✨'**
  String get encouragement2;

  /// 격려 메시지 3
  ///
  /// In ko, this message translates to:
  /// **'오늘도 멋진 하루를 보내고 있네요! 🌟'**
  String get encouragement3;

  /// 격려 메시지 4
  ///
  /// In ko, this message translates to:
  /// **'정말 대단해요! 자랑스러워요! 👏'**
  String get encouragement4;

  /// 격려 메시지 5
  ///
  /// In ko, this message translates to:
  /// **'완벽해요! 정말 잘했어요! 🎉'**
  String get encouragement5;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
