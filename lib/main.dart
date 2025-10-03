import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'generated/l10n/app_localizations.dart';
import 'character_view.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'home.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'language_manager.dart';
// Removed auth imports

// --- 앱 전체에서 사용할 색상 정의 ---
const Color bgColor = Color(0xFFF8F5EF);
const Color primaryColor = Color(0xFF737B69);
const Color secondaryColor = Color(0xFFB0B0B0);
const Color textColor = Color(0xFF3D3D3D);
const Color cardBgColor = Colors.white;

// 앱의 시작점
Future<void> main() async {
  // Flutter 바인딩을 먼저 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Supabase
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );

  // 언어 설정 로드
  await LanguageManager.loadSavedLanguage();

  // 타임존 초기화
  tz.initializeTimeZones();

  runApp(const AngelDiaryApp());
}

class AngelDiaryApp extends StatefulWidget {
  const AngelDiaryApp({super.key});

  @override
  State<AngelDiaryApp> createState() => _AngelDiaryAppState();
}

class _AngelDiaryAppState extends State<AngelDiaryApp> {
  bool _isLoading = true;
  bool _hasAngel = false;
  // Removed auth subscription

  @override
  void initState() {
    super.initState();
    _checkAngelStatus();
    // LanguageManager의 변경사항을 감지하기 위해 리스너 추가
    LanguageManager().addListener(_onLanguageChanged);
    // Removed auth state listener
  }

  @override
  void dispose() {
    LanguageManager().removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    setState(() {
      // 언어가 변경되면 UI를 다시 빌드
    });
  }

  // 천사 등록 여부 확인
  Future<void> _checkAngelStatus() async {
    try {
      // SharedPreferences에서 직접 천사 데이터 확인
      final prefs = await SharedPreferences.getInstance();
      final angelJson = prefs.getString('angel_data');

      setState(() {
        _hasAngel = angelJson != null && angelJson.isNotEmpty;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasAngel = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '천사일기',
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
        fontFamily: 'Oneprettynight', // 기본 폰트를 Pretendard로 설정
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
      home: _buildHome(),
    );
  }

  // Removed auth subscription disposal

  Widget _buildHome() {
    if (_isLoading) {
      return const LoadingScreen();
    }

    return _hasAngel ? const HomeScreen() : const OnboardingScreen();
  }
}

// 로딩 화면
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
class SplashScreen extends StatelessWidget {
  final VoidCallback onStartPressed;
  const SplashScreen({super.key, required this.onStartPressed});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      key: const ValueKey('splash'),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            l10n.splashMessage1,
            style: textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
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
          Column(
            children: [
              Text(
                l10n.splashMessage2,
                style: textTheme.bodyMedium,
                textAlign: TextAlign.center,
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
                onPressed: onStartPressed,
                child: Text(
                  l10n.startButton,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
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
    final l10n = AppLocalizations.of(context)!;

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
                Text(l10n.questionSubtitle, style: textTheme.bodyMedium),
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
                      fontSize: 16,
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
                      fontSize: 16,
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
  final List<String> _petTypes = ['강아지', '고양이', '기타'];
  String? _selectedPetType;

  final List<String> _petDescs = [
    '작고 하얀 복슬강아지',
    '용감하고 늠름한 친구',
    '애교많은 개냥이',
    '직접 입력',
  ];
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
        _buildControlSection('얼굴 타입', _selectedFaceType, 4, (value) {
          setState(() {
            _selectedFaceType = value;
          });
        }),

        // 얼굴 색상
        _buildControlSection('얼굴 색상', _selectedFaceColor, 6, (value) {
          setState(() {
            _selectedFaceColor = value;
          });
        }),

        // 꼬리
        _buildControlSection('꼬리', _selectedTailIndex, 4, (value) {
          setState(() {
            _selectedTailIndex = value;
          });
        }),
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
      feature: _selectedPetDesc == '직접 입력'
          ? _directInputController.text
          : _selectedPetDesc ?? '',
      animalType: _selectedPetType == '고양이' ? 'cat' : 'dog',
      faceType: _selectedFaceType,
      faceColor: _selectedFaceColor,
      bodyIndex: 1,
      emotionIndex: 1,
      tailIndex: _selectedTailIndex,
      createdAt: DateTime.now(),
    );

    // 전역 천사 데이터에 저장 (SharedPreferences에 자동 저장)
    await AngelDataManager.setCurrentAngel(angelData);

    // 천사 등록 완료 - 홈으로 이동
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  // 위젯이 화면에서 사라질 때 컨트롤러를 정리해줘야 메모리 누수가 없어
  @override
  void dispose() {
    _nameController.dispose();
    _directInputController.dispose(); // ✨ 직접 입력 컨트롤러도 dispose 추가
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                const Text(
                  '천사 등록하기',
                  style: TextStyle(fontSize: 43, color: textColor),
                ),
                const SizedBox(height: 30),

                // 1. 이름 입력창
                const Text(
                  '당신의 마음 속에 품은 아이의 이름을 입력해주세요.',
                  style: TextStyle(fontSize: 24, color: textColor),
                ),
                const SizedBox(height: 8), // ✨ Text와 TextField 사이에 간격 추가
                TextField(
                  controller: _nameController,
                  decoration: buildInputDecoration().copyWith(
                    // ✨ 공통 스타일 함수 사용
                    hintText: "ex) 행복, 별이",
                    hintStyle: TextStyle(fontSize: 16, color: Colors.grey[400]),
                  ),
                ),
                const SizedBox(height: 30),

                // 2. 펫 타입 선택
                const Text(
                  '아이는 어떤 종류에요?',
                  style: TextStyle(fontSize: 24, color: textColor),
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
                  style: TextStyle(fontSize: 24, color: textColor),
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
                  style: TextStyle(fontSize: 24, color: textColor),
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
                            fontSize: 22,
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
                                  animalType: _selectedPetType == '고양이'
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
                  child: const Text("천사 등록하기"),
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
                Text("괜찮아요.", style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 10),
                Text(
                  "우리에게는 새로운 시작이 있으니까요.\n당신의 마음속에 작은 씨앗을 심어볼까요? 당신의 천사와 함께 하게 될거에요.",
                  style: Theme.of(context).textTheme.bodyMedium,
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

  // 반응형 헤더 빌더
  Widget _buildResponsiveHeader() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 600; // 폴드4 펼쳐진 상태 기준

    if (isWideScreen) {
      // 펼쳐진 상태: Row로 쭉 spaceBetween
      return Row(
        children: [
          if (_currentStep > 0)
            IconButton(
              onPressed: () {
                setState(() {
                  _currentStep--;
                });
              },
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          Expanded(
            child: Text(
              _currentStep == 0 ? '천사 정보 입력' : '천사 커스터마이징',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      );
    } else {
      // 접힌 상태: Wrap으로 줄바꿈
      return Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (_currentStep > 0)
            IconButton(
              onPressed: () {
                setState(() {
                  _currentStep--;
                });
              },
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          Flexible(
            child: Text(
              _currentStep == 0 ? '천사 정보 입력' : '천사 커스터마이징',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
          minWidth: 300,
          minHeight: 400,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            // 헤더
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: _buildResponsiveHeader(),
            ),

            // 내용 영역
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
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "당신의 천사에 대해 알려주세요",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 30),

          // 이름 입력
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: '천사의 이름',
              hintText: '예: 루나, 별이, 소망이',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: primaryColor, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 특징 입력
          TextField(
            controller: _featureController,
            decoration: InputDecoration(
              labelText: '천사의 특징',
              hintText: '예: 따뜻한, 용감한, 지혜로운',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: primaryColor, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 동물 타입 선택
          const Text(
            '동물 타입',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildAnimalTypeCard('강아지', 'dog')),
              const SizedBox(width: 15),
              Expanded(child: _buildAnimalTypeCard('고양이', 'cat')),
            ],
          ),

          const Spacer(),

          // 다음 단계 버튼
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
              onPressed: _validateAndProceed,
              child: const Text(
                '다음 단계',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 커스터마이징 단계
  Widget _buildCustomizationStep() {
    return Column(
      children: [
        // 캐릭터 미리보기
        Container(
          height: 300,
          margin: const EdgeInsets.all(20),
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
              scaleFactor: 1.0, // 천사 생성 팝업에서는 원본 크기
            ),
          ),
        ),

        // 커스터마이징 컨트롤
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 귀 타입 선택
                _buildPartSelector('귀 타입', 4, selectedFaceType, (index) {
                  setState(() => selectedFaceType = index);
                }),
                const SizedBox(height: 15),

                // 패턴 색상 선택
                _buildPartSelector('패턴 색상', 6, selectedFaceColor, (index) {
                  setState(() => selectedFaceColor = index);
                }),
                const SizedBox(height: 15),

                // 꼬리 선택
                _buildPartSelector('꼬리', 4, selectedTailIndex, (index) {
                  setState(() => selectedTailIndex = index);
                }),

                const SizedBox(height: 30),

                // 완료 버튼
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
                    onPressed: _completeCreation,
                    child: const Text(
                      '천사 생성 완료',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 동물 타입 카드
  Widget _buildAnimalTypeCard(String text, String animalType) {
    return GestureDetector(
      onTap: () => setState(() => _selectedAnimalType = animalType),
      child: Container(
        height: 50,
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
              fontSize: 16,
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
    return Column(
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
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: count,
            itemBuilder: (context, index) {
              final itemIndex = index + 1;
              return GestureDetector(
                onTap: () => onSelect(itemIndex),
                child: Container(
                  width: 50,
                  height: 50,
                  margin: const EdgeInsets.only(right: 10),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('천사의 이름을 입력해주세요')));
      return;
    }

    if (_featureController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('천사의 특징을 입력해주세요')));
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

    // 전역 천사 데이터에 저장 (SharedPreferences에 자동 저장)
    await AngelDataManager.setCurrentAngel(angelData);

    // 팝업 닫기
    Navigator.of(context).pop();

    // 천사 등록 완료 - 홈으로 이동
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }
}

// Removed StorageConfirmationDialog - no longer needed

// Removed LoginScreen - no longer needed

// Removed all login/signup related functions

// 언어 선택 다이얼로그
class LanguageSelectionDialog extends StatelessWidget {
  const LanguageSelectionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
          maxHeight: MediaQuery.of(context).size.height * 0.6,
          minWidth: 300,
          minHeight: 200,
        ),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.languageSelection,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 30),
              ...LanguageManager.supportedLocales.map((locale) {
                final isSelected =
                    LanguageManager.currentLocale.languageCode ==
                    locale.languageCode;
                return Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected
                          ? primaryColor
                          : Colors.grey[200],
                      foregroundColor: isSelected ? Colors.white : textColor,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () async {
                      await LanguageManager.setLanguage(locale);
                      Navigator.of(context).pop();
                      // 언어 변경이 즉시 적용됨 (리스너를 통해)
                    },
                    child: Text(
                      LanguageManager.getLanguageName(locale),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

// 언어 선택 다이얼로그 표시 함수
void _showLanguageSelectionDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => const LanguageSelectionDialog(),
  );
}
