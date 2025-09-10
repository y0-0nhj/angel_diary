import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'character_view.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'services/photoshop_api_service.dart'; // ✨ 방금 만든 서비스 import
import 'package:firebase_core/firebase_core.dart';
import 'package:angel_diary/firebase_options.dart';
import 'home.dart';


// --- 앱 전체에서 사용할 색상 정의 ---
const Color bgColor = Color(0xFFF8F5EF);
const Color primaryColor = Color(0xFF737B69);
const Color secondaryColor = Color(0xFFB0B0B0);
const Color textColor = Color(0xFF3D3D3D);
const Color cardBgColor = Colors.white;


// 앱의 시작점
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const AngelDiaryApp());
}

class AngelDiaryApp extends StatelessWidget {
  const AngelDiaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '천사일기',
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
      home: const OnboardingScreen(),
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
              image: AssetImage('assets/images/backgrounds/bg1.png'), // 여기에 네 이미지 파일 경로를 적어줘!
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
        return QuestionScreen(onYesPressed: _showYesForm, onNoPressed: _showNoForm);
      case OnboardingStep.yesForm:
        return YesFormScreen();
      case OnboardingStep.noForm:
        return NoFormScreen();
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
    return Container(
      
      key: const ValueKey('splash'),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            "오늘의 약속 하나,\n너에게 닿는 발걸음 하나,\n세상 가장 따뜻한 약속",
            style: textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          Column(
            children: [
               Text("천사일기", style: textTheme.displayLarge),
               const SizedBox(height: 40),
               Image.asset('assets/images/illustrations/angel_dove.png', width: 250), // 샘플 비둘기 이미지
            ],
          ),
          Column(
            children: [
               Text(
                "가장 먼 미래는, 가장 소중한 지금으로 만들어집니다.\n마음 속 소망을 눈앞의 현실로 만들어드립니다.",
                style: textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                onPressed: onStartPressed,
                child: const Text("시작하기", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          )
        ],
      ),
    );
  }
}

// 2. 질문 화면
class QuestionScreen extends StatelessWidget {
  final VoidCallback onYesPressed;
  final VoidCallback onNoPressed;
  
  const QuestionScreen({super.key, required this.onYesPressed, required this.onNoPressed});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      key: const ValueKey('question'),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Card(
          elevation: 0,
          color: cardBgColor.withOpacity(0.7),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                //Image.asset('assets/images/illustrations/angel_question.png', width: 80),
                const SizedBox(height: 20),
                Text("반려동물과 함께 추억을\n 쌓은 적이 있으신가요?", style: textTheme.headlineSmall, textAlign: TextAlign.center),
                Text("(강아지, 고양이)", style: textTheme.bodyMedium),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor, foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                  ),
                  onPressed: onYesPressed,
                  child: const Text("예", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: secondaryColor, foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                  ),
                  onPressed: onNoPressed,
                  child: const Text("아니오", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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

  final List<String> _petDescs = ['작고 하얀 복슬강아지', '용감하고 늠름한 친구', '애교많은 개냥이', '직접 입력'];
  String? _selectedPetDesc;

  XFile? _pickedImage;

  // --- ✨ API 연동을 위한 상태 변수 추가 ---
  bool _isLoading = false; // API 호출 중 로딩 상태를 알려주는 변수
  Uint8List? _processedImageBytes; // 배경이 제거된 이미지 데이터를 담을 변수

  // 이미지 선택 함수
  Future<void> _pickImage() async {
    setState(() {
      _processedImageBytes = null;
    });
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _pickedImage = image;
      });
    }
  }


  // 등록 버튼 함수
  Future<void> _submit() async {
    if (_pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('반려동물의 사진을 먼저 등록해주세요!')),
      );
      return;
    }
    // TODO: API 호출 및 데이터 저장 로직
    
    setState(() {
      _isLoading = true;
      
    });

    try {
      // 2. 배경 제거 API 호출
      final apiService = PhotoshopApiService();
      final resultBytes = await apiService.removeBackground(File(_pickedImage!.path));

          // 3. 결과 처리
      if (resultBytes != null) {
        setState(() {
          _processedImageBytes = resultBytes; // 성공 시 결과 저장
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✨ 배경이 성공적으로 제거되었어요!')),
        );
      } else {
        throw Exception('API 처리 실패');
      }
    } catch (e) {
      // 4. 에러 처리
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이미지 처리에 실패했어요. 다른 사진으로 시도해보세요.')),
      );
    } finally {
      // 5. 로딩 종료 (성공/실패와 상관없이 항상 실행)
      setState(() {
        _isLoading = false;
      });
    }
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
        child: SingleChildScrollView( // ✨ 스크롤은 Card 안에서만 되도록 구조 변경
          child: Padding(
            padding: const EdgeInsets.all(25.0), // ✨ 내부 여백 조절
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('천사 등록하기', style: TextStyle(fontSize: 43, color: textColor)),
                const SizedBox(height: 30),

                // 1. 이름 입력창
                const Text(
                  '당신의 마음 속에 품은 아이의 이름을 입력해주세요.',
                  style: TextStyle(fontSize: 24, color: textColor),
                ),
                const SizedBox(height: 8), // ✨ Text와 TextField 사이에 간격 추가
                TextField(
                  controller: _nameController,
                  decoration: buildInputDecoration().copyWith( // ✨ 공통 스타일 함수 사용
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
                  value: _selectedPetType,
                  items: _petTypes.map((type) => DropdownMenuItem<String>(value: type, child: Text(type))).toList(),
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
                  value: _selectedPetDesc,
                  items: _petDescs.map((desc) => DropdownMenuItem<String>(value: desc, child: Text(desc))).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      _selectedPetDesc = value;
                    });
                  },
                ),
                const SizedBox(height: 10),

                // '직접 입력' 선택 시 나타나는 TextField
                if (_selectedPetDesc == '직접 입력')
                  Padding( // ✨ 약간의 여백 추가
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

                // ✨ --- 이미지 표시 영역 ---
                Center(
                  child: Column(
                    children: [
                      if (_isLoading) // 1. 로딩 중일 때
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40.0),
                          child: CircularProgressIndicator(),
                        )
                      else if (_processedImageBytes != null) // 2. 배경 제거 성공 시
                        Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12.0),
                              child: Image.memory(_processedImageBytes!, height: 200, fit: BoxFit.cover),
                            ),
                            const SizedBox(height: 10),
                            const Text("✨ 천사로 변신 완료! ✨", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                          ],
                        )
                      else if (_pickedImage != null) // 3. 원본 이미지만 선택했을 때
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: Image.file(File(_pickedImage!.path), height: 200, fit: BoxFit.cover),
                        ),

                      // ✨ 로딩 중이 아닐 때만 이미지 선택 버튼 표시
                      if (!_isLoading)
                        Padding(
                          padding: const EdgeInsets.only(top: 15.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white, foregroundColor: primaryColor,
                              side: BorderSide(color: primaryColor),
                              minimumSize: const Size(double.infinity, 70),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                            ),
                            onPressed: _pickImage,
                            child: Text(_pickedImage == null ? "이미지 선택" : "다른 이미지 선택", style: TextStyle(color: primaryColor)),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor, foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                  ),
                  onPressed: _submit,
                  child: Text(_isLoading ? "천사 등록 중..." : "천사 등록하기"),
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
          elevation: 0,
          color: cardBgColor.withOpacity(0.7),
           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                    backgroundColor: primaryColor, foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                  ),
                  onPressed: () {
                    // 천사 생성 팝업창 표시
                    _showAngelCreationPopup(context);
                  },
                  child: const Text("마음의 씨앗 심기", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                )
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
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
              child: Row(
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
              ),
            ),
            
            // 내용 영역
            Expanded(
              child: _currentStep == 0 ? _buildFormStep() : _buildCustomizationStep(),
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
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
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
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildAnimalTypeCard('강아지', 'dog'),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildAnimalTypeCard('고양이', 'cat'),
              ),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Center(
            child: CharacterView(
              animalType: _selectedAnimalType,
              faceType: selectedFaceType,
              faceColor: selectedFaceColor,
              bodyIndex: selectedBodyIndex,
              emotionIndex: selectedEmotionIndex,
              tailIndex: selectedTailIndex,
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    onPressed: _completeCreation,
                    child: const Text(
                      '천사 생성 완료',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
          color: _selectedAnimalType == animalType ? primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _selectedAnimalType == animalType ? Colors.white : textColor,
            ),
          ),
        ),
      ),
    );
  }

  // 파츠 선택기
  Widget _buildPartSelector(String title, int count, int selectedIndex, Function(int) onSelect) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
        const SizedBox(height: 8),
        Container(
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
                    color: selectedIndex == itemIndex ? primaryColor : Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selectedIndex == itemIndex ? primaryColor : Colors.grey[300]!,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$itemIndex',
                      style: TextStyle(
                        color: selectedIndex == itemIndex ? Colors.white : textColor,
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
        const SnackBar(content: Text('천사의 이름을 입력해주세요')),
      );
      return;
    }
    
    if (_featureController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('천사의 특징을 입력해주세요')),
      );
      return;
    }
    
    setState(() {
      _currentStep = 1;
    });
  }

  // 천사 생성 완료
  void _completeCreation() {
    // 천사 데이터 생성 및 저장
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
    
    // 전역 천사 데이터에 저장
    AngelDataManager.setCurrentAngel(angelData);
    
    // 팝업 닫기
    Navigator.of(context).pop();
    
    // 홈 화면으로 이동
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
    );
  }
}

