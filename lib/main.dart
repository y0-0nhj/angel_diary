import 'package:flutter/material.dart';
import 'character_view.dart';


// --- 앱 전체에서 사용할 색상 정의 ---
const Color bgColor = Color(0xFFF8F5EF);
const Color primaryColor = Color(0xFF737B69);
const Color secondaryColor = Color(0xFFB0B0B0);
const Color textColor = Color(0xFF3D3D3D);
const Color cardBgColor = Colors.white;

// 앱의 시작점
void main() {
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
        fontFamily: 'Pretendard', // 기본 폰트를 Pretendard로 설정
        textTheme: const TextTheme(
          // 대형 제목 - 브랜드/로고용
          displayLarge: TextStyle(fontFamily: 'Ongeulleap', fontSize: 48, fontWeight: FontWeight.bold, color: textColor),
          displayMedium: TextStyle(fontFamily: 'Oneprettynight', fontSize: 36, fontWeight: FontWeight.w600, color: textColor),
          
          // 헤드라인 - 섹션 제목용
          headlineLarge: TextStyle(fontFamily: 'MaruBuri', fontSize: 28, fontWeight: FontWeight.w700, color: textColor),
          headlineMedium: TextStyle(fontFamily: 'MaruBuri', fontSize: 24, fontWeight: FontWeight.w600, color: textColor),
          headlineSmall: TextStyle(fontFamily: 'MaruBuri', fontSize: 22, fontWeight: FontWeight.w500, color: textColor, height: 1.5),
          
          // 타이틀 - 카드/리스트 제목용
          titleLarge: TextStyle(fontFamily: 'Pretendard', fontSize: 20, fontWeight: FontWeight.w600, color: textColor),
          titleMedium: TextStyle(fontFamily: 'Pretendard', fontSize: 18, fontWeight: FontWeight.w500, color: textColor),
          titleSmall: TextStyle(fontFamily: 'Pretendard', fontSize: 16, fontWeight: FontWeight.w500, color: textColor),
          
          // 본문 텍스트
          bodyLarge: TextStyle(fontFamily: 'Pretendard', fontSize: 16, color: textColor, height: 1.6),
          bodyMedium: TextStyle(fontFamily: 'Pretendard', fontSize: 14, color: textColor, height: 1.6),
          bodySmall: TextStyle(fontFamily: 'Pretendard', fontSize: 12, color: textColor, height: 1.5),
          
          // 라벨/버튼 텍스트
          labelLarge: TextStyle(fontFamily: 'Pretendard', fontSize: 14, fontWeight: FontWeight.w600, color: textColor),
          labelMedium: TextStyle(fontFamily: 'Pretendard', fontSize: 12, fontWeight: FontWeight.w500, color: textColor),
          labelSmall: TextStyle(fontFamily: 'Pretendard', fontSize: 11, fontWeight: FontWeight.w500, color: textColor),
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
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset('assets/images/background.png'),
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
  // 폼 위젯들의 상태를 관리할 변수들
  final List<String> _petTypes = ['강아지', '고양이', '기타'];
  String? _selectedPetType;

  final List<String> _petDescs = ['작고 하얀 복슬강아지', '용감하고 늠름한 친구', '애교많은 개냥이', '직접 입력'];
  String? _selectedPetDesc;
  
  // 텍스트 입력창의 값을 가져오기 위한 컨트롤러
  final _nameController = TextEditingController();

  // 위젯이 화면에서 사라질 때 컨트롤러를 정리해줘야 메모리 누수가 없어
  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor, // 메인 파일에 정의된 bgColor 사용
      body: SingleChildScrollView( // 화면이 작아도 스크롤이 되도록 설정
        child: Padding(
          key: const ValueKey('yesForm'),
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 60.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start, // 라벨을 왼쪽에 정렬
            children: [
              const Center( // 제목만 가운데 정렬
                child: Text(
                  "반려동물 정보 등록",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
                ),
              ),
              const SizedBox(height: 40),

              // 1. 아이 종류 선택 드롭다운
              const Text("아이는 어떤 종류예요?", style: TextStyle(fontSize: 16, color: textColor)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: buildInputDecoration(), // 아래에 정의된 공통 스타일 사용
                hint: const Text("선택해주세요"),
                value: _selectedPetType,
                items: _petTypes.map((String value) {
                  return DropdownMenuItem<String>(value: value, child: Text(value));
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedPetType = newValue;
                  });
                },
              ),
              const SizedBox(height: 20),

              // 2. 아이 특징 선택 드롭다운
              const Text("아이는 어떤 친구예요?", style: TextStyle(fontSize: 16, color: textColor)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: buildInputDecoration(),
                hint: const Text("선택해주세요"),
                value: _selectedPetDesc,
                items: _petDescs.map((String value) {
                  if (value == '직접 입력') {
                    return DropdownMenuItem<String>(value: value, child: TextFormField(controller: _nameController));
                  }
                  return DropdownMenuItem<String>(value: value, child: Text(value));
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedPetDesc = newValue;
                  });
                },
              ),
              const SizedBox(height: 20),
              
              // 3. 아이 이름 입력창
              const Text("아이의 이름은 무엇인가요?", style: TextStyle(fontSize: 16, color: textColor)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: buildInputDecoration().copyWith(hintText: "이름을 입력해주세요"),
              ),
              const SizedBox(height: 30),

              // 4. 사진 등록, 커스터마이징 버튼 (디자인만 구현)
              Container( // 버튼처럼 보이게 하는 디자인
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(child: Text("가장 예쁘고 아름답던 사진을 등록해주세요.", style: TextStyle(color: textColor))),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  // 선택된 동물 종류를 기반으로 커스터마이징 화면으로 이동
                  String animalType = 'cat'; // 기본값
                  if (_selectedPetType == '강아지') {
                    animalType = 'dog';
                  } else if (_selectedPetType == '고양이') {
                    animalType = 'cat';
                  }
                  
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CharacterCustomizationScreen(animalType: animalType),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: primaryColor.withOpacity(0.3)),
                  ),
                  child: const Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.palette, color: primaryColor),
                        SizedBox(width: 8),
                        Text("2D 커스터마이징 하기", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // 5. 등록하기 버튼
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                ),
                onPressed: () {
                  // TODO: 등록하기 버튼 눌렀을 때 로직 구현
                  // 예: print('선택된 동물: $_selectedPetType, 특징: $_selectedPetDesc, 이름: ${_nameController.text}');
                },
                child: const Text("등록하기", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
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
                  "우리에게는 새로운 시작이 있으니까요.\n당신의 마음속에 작은 씨앗을 심어볼까요?",
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
                    // 마음의 씨앗 심기 - 기본값으로 고양이 커스터마이징 화면으로 이동
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CharacterCustomizationScreen(animalType: 'dog'),
                      ),
                    );
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
}
