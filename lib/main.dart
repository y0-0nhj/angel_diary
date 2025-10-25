// 앱의 진입점과 전역 테마/온보딩/분기 로직을 포함하는 메인 파일입니다.
// - 앱 초기화: Firebase, Supabase, Kakao SDK, Timezone, 언어 설정, 세션 복원
// - 전역 테마 구성: 색상, 폰트 패밀리, 로컬라이제이션 지원
// - 초기 분기: 첫 방문/로그인/게스트/천사 데이터 유무에 따라 홈/온보딩으로 라우팅
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:angel_diary/clients/supabase_client.dart';
import 'generated/l10n/app_localizations.dart';
import 'character_view.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'home.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'language_manager.dart';
import 'screens/auth/intro_signup.dart';
import 'models/angel_data.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart' as kakao;
import 'providers/angel_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/music_provider.dart';
import 'providers/app_provider.dart';
import 'services/deep_link_service.dart';

// --- 앱 전체에서 사용할 색상 정의 ---
const Color bgColor = Color(0xFFF8F5EF);
const Color primaryColor = Color(0xFF737B69);
const Color secondaryColor = Color(0xFFB0B0B0);
const Color textColor = Color(0xFF3D3D3D);
const Color cardBgColor = Colors.white;

/// 앱의 시작점.
///
/// 앱에서 사용되는 외부 SDK 및 런타임 의존성을 초기화하고, 저장된 언어/세션 상태를 복원한 후
/// 최상위 위젯인 `AngelDiaryApp`을 실행합니다.
Future<void> main() async {
  // Flutter 바인딩을 먼저 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // await dotenv.load(fileName: ".env");

  // Firebase 초기화: 알림/분석/원격 구성 등 Firebase 기반 기능 사용을 위해 필요
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Supabase 초기화: 인증/데이터 저장 등 Supabase 사용을 위한 클라이언트 준비
  await SupabaseClient().init();

  // 카카오 SDK 초기화: 소셜 로그인/연동 기능 사용을 위한 준비
  kakao.KakaoSdk.init(
    nativeAppKey: '41bafe186ed2ce2ceef68c2dd004b0b0', // 실제 네이티브 앱 키로 교체 필요
    javaScriptAppKey:
        'fdb84d1114ec854e0e72d1e4661247d9', // 실제 JavaScript 앱 키로 교체 필요
  );

  // 언어 설정 로드: 사용자가 저장한 언어 선호도 복원 (Locale 적용)
  await LanguageManager.loadSavedLanguage();

  // 타임존 초기화: 로컬 알림/시간 표시의 정확도를 위해 필요
  tz.initializeTimeZones();

  // 딥링크 서비스 초기화
  DeepLinkService().initialize();
  await DeepLinkService().handleInitialLink();

  runApp(const AngelDiaryApp());
}

/// 앱의 루트 위젯. Provider 설정과 전역 테마를 담당합니다.
class AngelDiaryApp extends StatefulWidget {
  const AngelDiaryApp({super.key});

  @override
  State<AngelDiaryApp> createState() => _AngelDiaryAppState();
}

class _AngelDiaryAppState extends State<AngelDiaryApp> {
  @override
  void initState() {
    super.initState();
    // LanguageManager의 변경사항을 감지하기 위해 리스너 추가
    LanguageManager().addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    LanguageManager().removeListener(_onLanguageChanged);
    super.dispose();
  }

  /// 언어 변경 리스너. Locale 변경 시 전체 위젯 트리를 재빌드합니다.
  void _onLanguageChanged() {
    setState(() {
      // 언어가 변경되면 UI를 다시 빌드
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AngelProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MusicProvider()),
        ChangeNotifierProvider(create: (_) => AppProvider()),
      ],
      child: MaterialApp(
        title: AppLocalizations.of(context)?.appTitle ?? 'Angel Diary',
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: LanguageManager.supportedLocales,
        locale: LanguageManager.currentLocale,
        theme: ThemeData(
          scaffoldBackgroundColor: bgColor,
          primaryColor: primaryColor,
          fontFamily: 'Cafe24Oneprettynight', // 기본 폰트를 Cafe24Oneprettynight로 설정
          textTheme: const TextTheme(
            // // 대형 제목 - 브랜드/로고용
            // displayLarge: TextStyle(fontFamily: 'Ongeulleap', fontSize: 48, fontWeight: FontWeight.bold, color: textColor),
            // displayMedium: TextStyle(fontFamily: 'Oneprettynight', fontSize: 36, fontWeight: FontWeight.w600, color: textColor),

            // // 헤드라인 - 섹션 제목용
            // headlineLarge: TextStyle(fontFamily: 'MaruBuri', fontSize: 28, fontWeight: FontWeight.w700, color: textColor),
            // headlineMedium: TextStyle(fontFamily: 'MaruBuri', fontSize: 24, fontWeight: FontWeight.w600, color: textColor),
            // headlineSmall: TextStyle(fontFamily: 'MaruBuri', fontSize: 22, fontWeight: FontWeight.w500, color: textColor, height: 1.5),

            // // 타이틀 - 카드/리스트 제목용
            // titleLarge: TextStyle(fontFamily: 'Pretendard', fontSize: 20, fontWeight: FontWeight.w600, color: textColor),
            // titleMedium: TextStyle(fontFamily: 'Pretendard', fontSize: 18, fontWeight: FontWeight.w500, color: textColor),
            // titleSmall: TextStyle(fontFamily: 'Pretendard', fontSize: 16, fontWeight: FontWeight.w500, color: textColor),

            // // 본문 텍스트
            // bodyLarge: TextStyle(fontFamily: 'Pretendard', fontSize: 16, color: textColor, height: 1.6),
            // bodyMedium: TextStyle(fontFamily: 'Pretendard', fontSize: 14, color: textColor, height: 1.6),
            // bodySmall: TextStyle(fontFamily: 'Pretendard', fontSize: 12, color: textColor, height: 1.5),

            // // 라벨/버튼 텍스트
            // labelLarge: TextStyle(fontFamily: 'Pretendard', fontSize: 14, fontWeight: FontWeight.w600, color: textColor),
            // labelMedium: TextStyle(fontFamily: 'Pretendard', fontSize: 12, fontWeight: FontWeight.w500, color: textColor),
            // labelSmall: TextStyle(fontFamily: 'Pretendard', fontSize: 11, fontWeight: FontWeight.w500, color: textColor),
          ),
        ),
        home: const AppInitializer(),
      ),
    );
  }
}

/// 앱 초기화를 담당하는 위젯
///
/// Provider를 통해 앱 상태를 초기화하고 적절한 화면으로 분기합니다.
class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  /// 앱 초기화
  Future<void> _initializeApp() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final angelProvider = Provider.of<AngelProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // 세션 복원
    await authProvider.restoreSession();

    // 앱 상태 초기화
    await appProvider.initializeApp(angelProvider, authProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<AppProvider, AngelProvider, AuthProvider>(
      builder: (context, appProvider, angelProvider, authProvider, child) {
        // 로딩 중이면 로딩 화면 표시
        if (appProvider.isLoading) {
          return const LoadingScreen();
        }

        // 에러가 있으면 에러 화면 표시
        if (appProvider.error != null) {
          return ErrorScreen(error: appProvider.error!);
        }

        // 화면 분기 로직
        return _buildHomeScreen(appProvider, angelProvider, authProvider);
      },
    );
  }

  /// 화면 분기 로직
  Widget _buildHomeScreen(
    AppProvider appProvider,
    AngelProvider angelProvider,
    AuthProvider authProvider,
  ) {
    print(
      '🎯 화면 분기 - 로그인: ${appProvider.isLoggedIn}, 천사: ${appProvider.hasAngel}, 게스트데이터: ${appProvider.hasGuestData}',
    );

    if (appProvider.isLoggedIn && appProvider.hasAngel) {
      // 로그인 + 천사 있음 → 홈 화면
      print('✅ → 홈 화면 (로그인 + 천사)');
      return const HomeScreen();
    } else if (appProvider.isLoggedIn && !appProvider.hasAngel) {
      // 로그인 + 천사 없음 → 온보딩 화면
      print('✅ → 온보딩 화면 (로그인 + 천사 없음)');
      return const OnboardingScreen();
    } else if (!appProvider.isLoggedIn && appProvider.hasGuestData) {
      if (appProvider.hasAngel) {
        // 게스트 모드 + 천사 있음 → 홈 화면
        print('✅ → 홈 화면 (게스트 모드 + 천사 있음)');
        return const HomeScreen();
      } else {
        // 게스트 모드 + 천사 없음 → 온보딩 화면
        print('✅ → 온보딩 화면 (게스트 모드 + 천사 없음)');
        return const OnboardingScreen();
      }
    } else {
      // 로그아웃 + 게스트 데이터 없음 → 온보딩 화면
      print('✅ → 온보딩 화면 (로그인 유도)');
      return const OnboardingScreen();
    }
  }
}

/// 에러 화면
class ErrorScreen extends StatelessWidget {
  final String error;

  const ErrorScreen({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 20),
            Text(
              '오류가 발생했습니다',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              error,
              style: const TextStyle(fontSize: 16, color: textColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // 앱 재시작
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const AppInitializer(),
                  ),
                );
              },
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }
}

// 로딩 화면
/// 앱 전역 로딩 화면.
/// - 초기 데이터/세션/리소스 로딩 동안 배경과 인디케이터를 표시합니다.
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/backgrounds/bg1.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
              SizedBox(height: 20),
              Text(
                '천사를 불러오는 중...',
                style: TextStyle(
                  fontFamily: 'Oneprettynight',
                  fontSize: 16,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 온보딩 단계를 정의 (어떤 화면을 보여줄지 결정)
enum OnboardingStep { splash, question, yesForm, noForm }

// 온보딩 전체 화면을 관리하는 메인 위젯
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // 현재 온보딩 단계를 관리하는 변수. 처음엔 splash 화면.
  OnboardingStep _currentStep = OnboardingStep.splash;

  // 다음 단계로 넘어가는 함수들
  void _showQuestionScreen() {
    setState(() {
      _currentStep = OnboardingStep.question;
    });
  }

  void _showYesForm() {
    setState(() {
      _currentStep = OnboardingStep.yesForm;
    });
  }

  void _showNoForm() {
    setState(() {
      _currentStep = OnboardingStep.noForm;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold는 앱 화면의 기본 구조를 제공
    return Scaffold(
      // 1. 배경 이미지 (맨 아래에 깔림)
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  'assets/images/backgrounds/bg1.png',
                ), // 여기에 네 이미지 파일 경로를 적어줘!
                fit: BoxFit.cover, // 이미지가 화면을 꽉 채우도록 설정
              ),
            ),
          ),

          // 2. 원래 있던 화면 내용 (배경 이미지 위에 보임)
          SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: _buildCurrentScreen(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentStep) {
      case OnboardingStep.splash:
        return SplashScreen(onStartPressed: _showQuestionScreen);
      case OnboardingStep.question:
        return QuestionScreen(
          onYesPressed: _showYesForm,
          onNoPressed: _showNoForm,
        );
      case OnboardingStep.yesForm:
        return const YesFormScreen();
      case OnboardingStep.noForm:
        return const NoFormScreen();
    }
  }
}

// --- 각 화면을 구성하는 위젯들 ---

// 1. 스플래시 화면
class SplashScreen extends StatefulWidget {
  final VoidCallback onStartPressed;
  const SplashScreen({super.key, required this.onStartPressed});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    if (l10n == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      key: const ValueKey('splash'),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            l10n.splashMessage1,
            style: textTheme.bodyMedium,
            textAlign: TextAlign.center,
            textScaleFactor: 1.2,
          ),
          const SizedBox(height: 10), // 메시지와 제목 사이 간격
          Column(
            children: [
              Text(l10n.appTitle, style: textTheme.displayLarge),
              const SizedBox(height: 40),
              Image.asset(
                'assets/images/illustrations/angel_dove.png',
                width: 250,
              ), // 샘플 비둘기 이미지
            ],
          ),
          const SizedBox(height: 30), // 이미지와 하단 메시지 사이 간격
          Column(
            children: [
              Text(
                l10n.splashMessage2,
                style: textTheme.bodySmall,
                textAlign: TextAlign.center,
                textScaleFactor: 1.2,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                onPressed: widget.onStartPressed,
                child: Text(
                  l10n.startButton,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(), // 하단에 여백 추가
        ],
      ),
    );
  }
}

// 2. 질문 화면
class QuestionScreen extends StatelessWidget {
  final VoidCallback onYesPressed;
  final VoidCallback onNoPressed;

  const QuestionScreen({
    super.key,
    required this.onYesPressed,
    required this.onNoPressed,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    if (l10n == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Center(
      key: const ValueKey('question'),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Card(
          color: cardBgColor.withOpacity(0.7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                //Image.asset('assets/images/illustrations/angel_question.png', width: 80),
                const SizedBox(height: 20),
                Text(
                  l10n.questionTitle,
                  style: textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                Text(
                  l10n.questionSubtitle,
                  style: textTheme.bodyMedium,
                  textScaleFactor: 1.4,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: onYesPressed,
                  child: Text(
                    l10n.yesButton,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: secondaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: onNoPressed,
                  child: Text(
                    l10n.noButton,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// YesFormScreen 위젯을 StatefulWidget으로 변경
class YesFormScreen extends StatefulWidget {
  const YesFormScreen({super.key});

  @override
  State<YesFormScreen> createState() => _YesFormScreenState();
}

class _YesFormScreenState extends State<YesFormScreen> {
  // 텍스트 입력창의 값을 가져오기 위한 컨트롤러
  final _nameController = TextEditingController();
  final _directInputController = TextEditingController();

  // 폼 위젯들의 상태를 관리할 변수들
  List<String> _petTypes = [];
  String? _selectedPetType;

  List<String> _petDescs = [];
  String? _selectedPetDesc;

  File? _pickedImage; // 사용자가 선택한 이미지 파일

  // 커스터마이징 관련 변수들
  int _selectedFaceType = 1; // 얼굴 타입 (1-4)
  int _selectedFaceColor = 1; // 얼굴 색상 (1-6)
  int _selectedTailIndex = 1; // 꼬리 (1-4)

  // 이미지 선택 함수
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  // 커스터마이징 컨트롤 위젯
  Widget _buildCustomizationControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 얼굴 타입
        _buildControlSection(
          AppLocalizations.of(context)!.faceType,
          _selectedFaceType,
          4,
          (value) {
            setState(() {
              _selectedFaceType = value;
            });
          },
        ),

        // 얼굴 색상
        _buildControlSection(
          AppLocalizations.of(context)!.faceColor,
          _selectedFaceColor,
          6,
          (value) {
            setState(() {
              _selectedFaceColor = value;
            });
          },
        ),

        // 꼬리
        _buildControlSection(
          AppLocalizations.of(context)!.tail,
          _selectedTailIndex,
          4,
          (value) {
            setState(() {
              _selectedTailIndex = value;
            });
          },
        ),
      ],
    );
  }

  // 개별 컨트롤 섹션 위젯
  Widget _buildControlSection(
    String title,
    int currentValue,
    int maxValue,
    Function(int) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(maxValue, (index) {
              final value = index + 1;
              final isSelected = currentValue == value;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(value),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected ? primaryColor : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? primaryColor : Colors.grey[300]!,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$value',
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // 등록 버튼 함수
  Future<void> _submit() async {
    if (_pickedImage == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('반려동물의 사진을 먼저 등록해주세요!')));
      return;
    }

    // 천사 데이터 생성
    final angelData = AngelData(
      name: _nameController.text,
      feature: _selectedPetDesc == AppLocalizations.of(context)!.petDesc4
          ? _directInputController.text
          : _selectedPetDesc ?? '',
      animalType: _selectedPetType == AppLocalizations.of(context)!.petTypeCat
          ? 'cat'
          : 'dog',
      faceType: _selectedFaceType,
      faceColor: _selectedFaceColor,
      bodyIndex: 1,
      emotionIndex: 1,
      tailIndex: _selectedTailIndex,
      createdAt: DateTime.now(),
    );

    // Provider를 통해 천사 데이터 저장
    final angelProvider = Provider.of<AngelProvider>(context, listen: false);
    final appProvider = Provider.of<AppProvider>(context, listen: false);

    await angelProvider.setAngel(angelData);
    appProvider.onAngelCreated();

    // 천사 등록 완료 - 홈으로 이동
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  // 위젯이 화면에서 사라질 때 컨트롤러를 정리해줘야 메모리 누수가 없어
  @override
  void initState() {
    super.initState();
    // initState에서는 다국어 데이터 초기화를 하지 않음
    // build() 메서드에서 동적으로 처리
  }

  void _initializePetData() {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;

    _petTypes = [l10n.petTypeDog, l10n.petTypeCat, l10n.petTypeOther];
    _petDescs = [l10n.petDesc1, l10n.petDesc2, l10n.petDesc3, l10n.petDesc4];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _directInputController.dispose(); // ✨ 직접 입력 컨트롤러도 dispose 추가
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // build() 메서드에서 다국어 데이터 초기화
    _initializePetData();

    return Padding(
      padding: const EdgeInsets.all(37.0),
      child: Card(
        elevation: 0,
        color: cardBgColor.withOpacity(0.85), // ✨ 투명도 살짝 조절
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          // ✨ 스크롤은 Card 안에서만 되도록 구조 변경
          child: Padding(
            padding: const EdgeInsets.all(25.0), // ✨ 내부 여백 조절
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.angelRegistration,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontFamily:
                        LanguageManager.currentLocale.languageCode == 'ko'
                        ? 'Cafe24Oneprettynight'
                        : null,
                  ),
                ),
                const SizedBox(height: 30),

                // 1. 이름 입력창
                Text(
                  AppLocalizations.of(context)!.nameInputLabel,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontFamily:
                        LanguageManager.currentLocale.languageCode == 'ko'
                        ? 'Cafe24Oneprettynight'
                        : null,
                  ),
                ),
                const SizedBox(height: 8), // ✨ Text와 TextField 사이에 간격 추가
                TextField(
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  controller: _nameController,
                  decoration: buildInputDecoration().copyWith(
                    // ✨ 공통 스타일 함수 사용
                    hintText: AppLocalizations.of(context)!.nameInputHint,
                    hintStyle: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // 2. 펫 타입 선택
                Text(
                  AppLocalizations.of(context)!.petTypeLabel,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontFamily:
                        LanguageManager.currentLocale.languageCode == 'ko'
                        ? 'Cafe24Oneprettynight'
                        : null,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  decoration: buildInputDecoration(), // ✨ 공통 스타일 함수 사용
                  initialValue: _selectedPetType,
                  items: _petTypes
                      .map(
                        (type) => DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        ),
                      )
                      .toList(),
                  onChanged: (String? value) {
                    setState(() {
                      _selectedPetType = value;
                    });
                  },
                ),
                const SizedBox(height: 30),

                // 3. 펫 설명 선택 드롭다운
                const Text(
                  '아이는 어떤 모습이에요?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  decoration: buildInputDecoration(), // ✨ 공통 스타일 함수 사용
                  initialValue: _selectedPetDesc,
                  items: _petDescs
                      .map(
                        (desc) => DropdownMenuItem<String>(
                          value: desc,
                          child: Text(desc),
                        ),
                      )
                      .toList(),
                  onChanged: (String? value) {
                    setState(() {
                      _selectedPetDesc = value;
                    });
                  },
                ),
                const SizedBox(height: 10),

                // '직접 입력' 선택 시 나타나는 TextField
                if (_selectedPetDesc == '직접 입력')
                  Padding(
                    // ✨ 약간의 여백 추가
                    padding: const EdgeInsets.only(top: 8.0),
                    child: TextField(
                      controller: _directInputController,
                      decoration: buildInputDecoration().copyWith(
                        hintText: "반려동물의 특징을 직접 입력해주세요",
                      ),
                    ),
                  ),
                const SizedBox(height: 30),

                // 4. 이미지 선택 버튼
                const Text(
                  '가장 아름답고 예뻤던 아이의 전신 모습을 선택해주세요.',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 15),

                // 이미지 표시 영역
                Center(
                  child: Column(
                    children: [
                      if (_pickedImage != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: Image.file(
                            File(_pickedImage!.path),
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate,
                                size: 50,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '사진을 선택해주세요',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 20),

                      // 이미지 선택 버튼
                      ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.add_photo_alternate),
                        label: Text(
                          _pickedImage == null ? "이미지 선택" : "다른 이미지 선택",
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 이미지가 선택된 경우에만 커스터마이징 뷰 표시
                if (_pickedImage != null) ...[
                  const SizedBox(height: 30),

                  // 천사 미리보기 섹션
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '🎨 천사 캐릭터 커스터마이징',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 15),

                        // 천사 미리보기 영역
                        Container(
                          height: 300,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: cardBgColor,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Stack(
                            children: [
                              // 천사 캐릭터 (앞쪽에)
                              Center(
                                child: CharacterView(
                                  animalType:
                                      _selectedPetType ==
                                          AppLocalizations.of(
                                            context,
                                          )!.petTypeCat
                                      ? 'cat'
                                      : 'dog',
                                  faceType: _selectedFaceType,
                                  faceColor: _selectedFaceColor,
                                  bodyIndex: 1, // 기본값 고정
                                  emotionIndex: 1, // 기본값 고정
                                  tailIndex: _selectedTailIndex,
                                  scaleFactor: 1, // 4분의 1 크기 (2.0 / 4 = 0.5)
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // 커스터마이징 컨트롤
                        _buildCustomizationControls(),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: _submit,
                  child: Text(
                    AppLocalizations.of(context)!.angelRegistration,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily:
                          LanguageManager.currentLocale.languageCode == 'ko'
                          ? 'Cafe24Oneprettynight'
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 입력창 스타일을 하나로 통일해서 재사용
  InputDecoration buildInputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
    );
  }
}

// 4. "아니오" 폼 화면
class NoFormScreen extends StatelessWidget {
  const NoFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const ValueKey('noForm'),
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Card(
          color: cardBgColor.withOpacity(0.7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "괜찮아요.",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 10),
                Text(
                  "우리에게는 새로운 시작이 있으니까요.\n당신의 마음속에 작은 씨앗을 심어볼까요? 당신의 천사와 함께 하게 될거에요.",
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {
                    // 천사 생성 팝업창 표시
                    _showAngelCreationPopup(context);
                  },
                  child: const Text(
                    "마음의 씨앗 심기",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 천사 생성 팝업창 표시
  void _showAngelCreationPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // 배경 터치로 닫기 방지
      builder: (context) => const AngelCreationPopup(),
    );
  }
}

// 천사 생성 통합 팝업창
class AngelCreationPopup extends StatefulWidget {
  const AngelCreationPopup({super.key});

  @override
  State<AngelCreationPopup> createState() => _AngelCreationPopupState();
}

class _AngelCreationPopupState extends State<AngelCreationPopup> {
  // 폼 관련 변수들
  final _nameController = TextEditingController();
  final _featureController = TextEditingController();
  String _selectedAnimalType = 'dog';

  // 단계 관리
  int _currentStep = 0; // 0: 폼 입력, 1: 커스터마이징

  // 커스터마이징 관련 변수들
  int selectedFaceType = 1;
  int selectedFaceColor = 1;
  int selectedBodyIndex = 1;
  int selectedEmotionIndex = 1;
  int selectedTailIndex = 1;

  @override
  void dispose() {
    _nameController.dispose();
    _featureController.dispose();
    super.dispose();
  }

  // 모던한 반응형 헤더 빌더
  Widget _buildResponsiveHeader() {
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final isVerySmallScreen = screenHeight < 600;
    final isSmallScreen = screenHeight < 700;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor,
            primaryColor.withOpacity(0.8),
            primaryColor.withOpacity(0.9),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 상단 네비게이션 바
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isVerySmallScreen ? 12 : 16,
              vertical: isVerySmallScreen ? 8 : 12,
            ),
            child: Row(
              children: [
                // 뒤로가기 버튼 (모던한 스타일)
                if (_currentStep > 0)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          _currentStep--;
                        });
                      },
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: isVerySmallScreen ? 18 : 20,
                      ),
                      padding: EdgeInsets.all(isVerySmallScreen ? 8 : 10),
                      constraints: BoxConstraints(
                        minWidth: isVerySmallScreen ? 36 : 40,
                        minHeight: isVerySmallScreen ? 36 : 40,
                      ),
                    ),
                  ),

                // 제목 영역
                Expanded(
                  child: Column(
                    children: [
                      // 단계 표시기
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isVerySmallScreen ? 8 : 12,
                          vertical: isVerySmallScreen ? 4 : 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '${_currentStep + 1}/2',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isVerySmallScreen ? 12 : 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(height: isVerySmallScreen ? 6 : 8),

                      // 메인 제목
                      Text(
                        _currentStep == 0 ? '천사 정보 입력' : '천사 커스터마이징',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isVerySmallScreen
                              ? 16
                              : (isSmallScreen ? 18 : 20),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // 닫기 버튼 (모던한 스타일)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: isVerySmallScreen ? 18 : 20,
                    ),
                    padding: EdgeInsets.all(isVerySmallScreen ? 8 : 10),
                    constraints: BoxConstraints(
                      minWidth: isVerySmallScreen ? 36 : 40,
                      minHeight: isVerySmallScreen ? 36 : 40,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 진행률 바
          Container(
            height: 3,
            margin: EdgeInsets.symmetric(
              horizontal: isVerySmallScreen ? 12 : 16,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (_currentStep + 1) / 2,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.white.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.5),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.height < 700;
    final isVerySmallScreen = screenSize.height < 600;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: screenSize.width * 0.95,
          maxHeight: screenSize.height * (isVerySmallScreen ? 0.95 : 0.9),
          minWidth: 300,
          minHeight: isVerySmallScreen ? 350 : 400,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 모던한 헤더
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: _buildResponsiveHeader(),
            ),

            // 내용 영역 (유연한 높이)
            Expanded(
              child: _currentStep == 0
                  ? _buildFormStep()
                  : _buildCustomizationStep(),
            ),
          ],
        ),
      ),
    );
  }

  // 폼 입력 단계
  Widget _buildFormStep() {
    final l10n = AppLocalizations.of(context)!;
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.height < 700;
    final isVerySmallScreen = screenSize.height < 600;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isVerySmallScreen ? 20.0 : 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.customizationTitle,
            style: TextStyle(
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: textColor,
              fontFamily: LanguageManager.currentLocale.languageCode == 'ko'
                  ? 'Cafe24Oneprettynight'
                  : null,
            ),
          ),
          SizedBox(height: isVerySmallScreen ? 20 : 30),

          // 이름 입력
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: l10n.angelNameLabel,
              hintText: l10n.nameInputHint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: primaryColor, width: 2),
              ),
            ),
          ),
          SizedBox(height: isVerySmallScreen ? 15 : 20),

          // 특징 입력
          TextField(
            controller: _featureController,
            decoration: InputDecoration(
              labelText: l10n.angelFeatureLabel,
              hintText: l10n.featureRequired,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: primaryColor, width: 2),
              ),
            ),
          ),
          SizedBox(height: isVerySmallScreen ? 15 : 20),

          // 동물 타입 선택
          Text(
            l10n.animalTypeLabel,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
              fontFamily: LanguageManager.currentLocale.languageCode == 'ko'
                  ? 'Cafe24Oneprettynight'
                  : null,
            ),
          ),
          SizedBox(height: isVerySmallScreen ? 8 : 10),
          Row(
            children: [
              Expanded(child: _buildAnimalTypeCard(l10n.petTypeDog, 'dog')),
              SizedBox(width: isVerySmallScreen ? 10 : 15),
              Expanded(child: _buildAnimalTypeCard(l10n.petTypeCat, 'cat')),
            ],
          ),

          SizedBox(height: isVerySmallScreen ? 20 : 30),

          // 다음 단계 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, isVerySmallScreen ? 45 : 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: _validateAndProceed,
              child: Text(
                l10n.nextStep,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: LanguageManager.currentLocale.languageCode == 'ko'
                      ? 'Cafe24Oneprettynight'
                      : null,
                ),
              ),
            ),
          ),
          SizedBox(height: isVerySmallScreen ? 15 : 20), // 하단 여백 추가
        ],
      ),
    );
  }

  // 커스터마이징 단계
  Widget _buildCustomizationStep() {
    final l10n = AppLocalizations.of(context)!;
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.height < 700;
    final isVerySmallScreen = screenSize.height < 600;

    return SingleChildScrollView(
      child: Column(
        children: [
          // 캐릭터 미리보기 (반응형 높이)
          Container(
            height: isVerySmallScreen ? 150 : (isSmallScreen ? 200 : 250),
            margin: EdgeInsets.all(isVerySmallScreen ? 15 : 20),
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: CharacterView(
                animalType: _selectedAnimalType,
                faceType: selectedFaceType,
                faceColor: selectedFaceColor,
                bodyIndex: selectedBodyIndex,
                emotionIndex: selectedEmotionIndex,
                tailIndex: selectedTailIndex,
                scaleFactor: isVerySmallScreen
                    ? 0.6
                    : (isSmallScreen ? 0.8 : 1.0), // 작은 화면에서는 크기 조정
              ),
            ),
          ),

          // 커스터마이징 컨트롤
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isVerySmallScreen ? 15 : 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 귀 타입 선택
                _buildPartSelector('귀 타입', 4, selectedFaceType, (index) {
                  setState(() => selectedFaceType = index);
                }),
                SizedBox(height: isVerySmallScreen ? 10 : 15),

                // 패턴 색상 선택
                _buildPartSelector('패턴 색상', 6, selectedFaceColor, (index) {
                  setState(() => selectedFaceColor = index);
                }),
                SizedBox(height: isVerySmallScreen ? 10 : 15),

                // 꼬리 선택
                _buildPartSelector(
                  AppLocalizations.of(context)!.tailSelector,
                  4,
                  selectedTailIndex,
                  (index) {
                    setState(() => selectedTailIndex = index);
                  },
                ),

                SizedBox(height: isVerySmallScreen ? 20 : 30),

                // 완료 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: Size(
                        double.infinity,
                        isVerySmallScreen ? 45 : 50,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: _completeCreation,
                    child: Text(
                      l10n.completeCreation,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily:
                            LanguageManager.currentLocale.languageCode == 'ko'
                            ? 'Cafe24Oneprettynight'
                            : null,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: isVerySmallScreen ? 15 : 20), // 하단 여백 추가
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 동물 타입 카드
  Widget _buildAnimalTypeCard(String text, String animalType) {
    final screenSize = MediaQuery.of(context).size;
    final isVerySmallScreen = screenSize.height < 600;

    return GestureDetector(
      onTap: () => setState(() => _selectedAnimalType = animalType),
      child: Container(
        height: isVerySmallScreen ? 45 : 50,
        decoration: BoxDecoration(
          color: _selectedAnimalType == animalType
              ? primaryColor
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: isVerySmallScreen ? 14 : 16,
              fontWeight: FontWeight.bold,
              color: _selectedAnimalType == animalType
                  ? Colors.white
                  : textColor,
            ),
          ),
        ),
      ),
    );
  }

  // 파츠 선택기
  Widget _buildPartSelector(
    String title,
    int count,
    int selectedIndex,
    Function(int) onSelect,
  ) {
    final screenSize = MediaQuery.of(context).size;
    final isVerySmallScreen = screenSize.height < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isVerySmallScreen ? 14 : 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        SizedBox(height: isVerySmallScreen ? 6 : 8),
        SizedBox(
          height: isVerySmallScreen ? 50 : 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: count,
            itemBuilder: (context, index) {
              final itemIndex = index + 1;
              return GestureDetector(
                onTap: () => onSelect(itemIndex),
                child: Container(
                  width: isVerySmallScreen ? 45 : 50,
                  height: isVerySmallScreen ? 45 : 50,
                  margin: EdgeInsets.only(right: isVerySmallScreen ? 8 : 10),
                  decoration: BoxDecoration(
                    color: selectedIndex == itemIndex
                        ? primaryColor
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selectedIndex == itemIndex
                          ? primaryColor
                          : Colors.grey[300]!,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$itemIndex',
                      style: TextStyle(
                        color: selectedIndex == itemIndex
                            ? Colors.white
                            : textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 폼 검증 및 다음 단계로 진행
  void _validateAndProceed() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.nameRequired)),
      );
      return;
    }

    if (_featureController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.featureRequired)),
      );
      return;
    }

    setState(() {
      _currentStep = 1;
    });
  }

  // 천사 생성 완료
  Future<void> _completeCreation() async {
    // 천사 데이터 생성
    final angelData = AngelData(
      name: _nameController.text,
      feature: _featureController.text,
      animalType: _selectedAnimalType,
      faceType: selectedFaceType,
      faceColor: selectedFaceColor,
      bodyIndex: selectedBodyIndex,
      emotionIndex: selectedEmotionIndex,
      tailIndex: selectedTailIndex,
      createdAt: DateTime.now(),
    );

    // 저장 확인 다이얼로그 표시
    final shouldSave = await _showStorageConfirmationDialog(context, angelData);

    if (shouldSave == true) {
      // 팝업 닫기
      Navigator.of(context).pop();

      // 회원가입 화면으로 이동 (천사 데이터를 전달)
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => IntroSignupScreen(angelData: angelData),
        ),
      );
    } else if (shouldSave == false) {
      // Provider를 통해 천사 데이터 저장
      final angelProvider = Provider.of<AngelProvider>(context, listen: false);
      final appProvider = Provider.of<AppProvider>(context, listen: false);

      await angelProvider.setAngel(angelData);
      appProvider.onAngelCreated();

      // 팝업 닫기
      Navigator.of(context).pop();

      // 안내 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.angelNotSaved)),
      );

      // 천사 등록 완료 - 홈으로 이동
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
    // shouldSave == null인 경우 (다이얼로그 취소) 아무것도 하지 않음
  }

  // 저장 확인 다이얼로그 표시
  Future<bool?> _showStorageConfirmationDialog(
    BuildContext context,
    AngelData angelData,
  ) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StorageConfirmationDialog(angelData: angelData),
    );
  }
}

// 저장 확인 다이얼로그
class StorageConfirmationDialog extends StatelessWidget {
  final AngelData angelData;

  const StorageConfirmationDialog({super.key, required this.angelData});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 천사 이미지 미리보기
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: primaryColor.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: 8, // 오른쪽으로 8px 이동
                    top: 0,
                    bottom: 0,
                    child: CharacterView(
                      animalType: angelData.animalType,
                      faceType: angelData.faceType,
                      faceColor: angelData.faceColor,
                      bodyIndex: angelData.bodyIndex,
                      emotionIndex: angelData.emotionIndex,
                      tailIndex: angelData.tailIndex,
                      scaleFactor: 0.5, // 4분의 1 크기로 축소
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 제목
            Text(
              l10n.angelCreated,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryColor,
                fontFamily: LanguageManager.currentLocale.languageCode == 'ko'
                    ? 'Cafe24Oneprettynight'
                    : null,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 15),

            // 부제목
            Text(
              l10n.angelCreatedSubtitle,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                fontFamily: LanguageManager.currentLocale.languageCode == 'ko'
                    ? 'Cafe24Oneprettynight'
                    : null,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 30),

            // 보관하기 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () {
                  // 다이얼로그 닫기 (true 반환)
                  Navigator.of(context).pop(true);
                },
                child: Text(
                  l10n.saveNow,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily:
                        LanguageManager.currentLocale.languageCode == 'ko'
                        ? 'Cafe24Oneprettynight'
                        : null,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 나중에 보관하기 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.grey[700],
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(false),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.saveLater,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily:
                            LanguageManager.currentLocale.languageCode == 'ko'
                            ? 'Cafe24Oneprettynight'
                            : null,
                      ),
                    ),
                    Text(
                      l10n.saveLaterWarning,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontFamily:
                            LanguageManager.currentLocale.languageCode == 'ko'
                            ? 'Cafe24Oneprettynight'
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
