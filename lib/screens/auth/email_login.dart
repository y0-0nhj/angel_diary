import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../common/constants/colors.dart';
import '../../services/auth/auth_service.dart';
import '../../services/user_profile_service.dart';
import '../../models/user_profile.dart';
import '../../models/angel_data.dart';
import '../../managers/angel_data_manager.dart' as adm;
import '../../home.dart';
import 'email_signup.dart';

class EmailLoginScreen extends StatefulWidget {
  final AngelData? angelData;

  const EmailLoginScreen({super.key, this.angelData});

  @override
  State<EmailLoginScreen> createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends State<EmailLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = AuthService();
      final response = await authService.signInWithEmailPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (response.user != null) {
        // 로그인 상태 저장
        await authService.saveLoginState(response.user!.email ?? '');

        // 로그인 성공 콜백 트리거
        AuthService.triggerLoginSuccess();

        // 천사 데이터 처리
        if (widget.angelData != null) {
          await _handleAngelDataAfterLogin(response.user!, widget.angelData!);
        } else {
          // 기존 사용자의 천사 데이터 로드
          await _loadExistingAngelData(response.user!);
        }

        if (mounted) {
          // 성공 메시지 표시
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('로그인에 성공했습니다!'),
              backgroundColor: AppColors.success,
            ),
          );

          // 홈 화면으로 이동
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false,
          );
        }
      } else {
        throw Exception('로그인에 실패했습니다.');
      }
    } catch (e) {
      print('❌ 로그인 에러: $e');
      print('🔍 에러 타입: ${e.runtimeType}');

      if (mounted) {
        String errorMessage = '로그인에 실패했습니다.';

        if (e.toString().contains('Email not confirmed')) {
          errorMessage = '이메일 인증이 필요합니다. 이메일을 확인하고 인증 링크를 클릭해주세요.';
        } else if (e.toString().contains('Invalid login credentials')) {
          errorMessage = '이메일 또는 비밀번호가 올바르지 않습니다.';
        } else if (e.toString().contains('Invalid email')) {
          errorMessage = '올바른 이메일 형식을 입력해주세요.';
        } else if (e.toString().contains('Password should be at least')) {
          errorMessage = '비밀번호는 6자 이상이어야 합니다.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleAngelDataAfterLogin(
    User user,
    AngelData angelData,
  ) async {
    try {
      // 천사 데이터를 SharedPreferences에 저장
      await adm.AngelDataManager.setCurrentAngel(angelData);

      final userProfileService = UserProfileService();

      // 기존 사용자 프로필 조회
      final existingProfile = await userProfileService.getUserProfileById(
        user.id,
      );

      if (existingProfile != null) {
        // 기존 프로필이 있으면 천사 데이터만 업데이트
        await userProfileService.updateAngelData(user.id, angelData.toJson());
        debugPrint('기존 사용자 프로필에 천사 데이터 업데이트 완료');
      } else {
        // 새 사용자 프로필 생성
        final newProfile = UserProfile(
          id: user.id,
          email: user.email ?? '',
          nickname: '익명의 천사',
          createdAt: DateTime.now(),
          lastActiveAt: DateTime.now(),
          pushNotificationEnabled: true,
          languagePreference: 'ko',
          exp: 0,
          level: 1,
          acorns: 0,
          isPremiumUser: false,
          angelData: angelData.toJson(),
        );

        await userProfileService.upsertUserProfile(newProfile);
        debugPrint('새 사용자 프로필 생성 및 천사 데이터 저장 완료');
      }
    } catch (e) {
      debugPrint('천사 데이터 저장 중 오류 발생: $e');
    }
  }

  Future<void> _loadExistingAngelData(User user) async {
    try {
      final userProfileService = UserProfileService();
      final userProfile = await userProfileService.getUserProfileById(user.id);

      if (userProfile?.angelData != null) {
        final angelData = AngelData.fromJson(userProfile!.angelData!);
        await adm.AngelDataManager.setCurrentAngel(angelData);
        debugPrint('기존 천사 데이터 로드 완료');
      }
    } catch (e) {
      debugPrint('기존 천사 데이터 로드 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          '이메일 로그인',
          style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8F5EF), // bgColor
              Color(0xFFF0EDE5), // 연한 베이지
              Color(0xFFE8E5DD), // 더 연한 베이지
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 32.0,
              vertical: 40.0,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),

                  // 제목
                  Text(
                    '천사일기에\n다시 오신 것을 환영합니다!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                      fontFamily: 'Cafe24Oneprettynight',
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    '이메일과 비밀번호를 입력해주세요.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontFamily: 'Cafe24Oneprettynight',
                    ),
                  ),

                  const SizedBox(height: 40),

                  // 이메일 입력
                  _buildInputSection(
                    label: '이메일',
                    child: TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'example@gmail.com',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '이메일을 입력해주세요.';
                        }
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value)) {
                          return '올바른 이메일 형식을 입력해주세요.';
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 비밀번호 입력
                  _buildInputSection(
                    label: '비밀번호',
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: '비밀번호를 입력하세요',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey[600],
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '비밀번호를 입력해주세요.';
                        }
                        if (value.length < 6) {
                          return '비밀번호는 6자 이상이어야 합니다.';
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 비밀번호 찾기 및 이메일 재전송
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => _showPasswordResetDialog(),
                        child: Text(
                          '비밀번호를 잊으셨나요?',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 14,
                            fontFamily: 'Cafe24Oneprettynight',
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => _resendEmailVerification(),
                        child: Text(
                          '인증 이메일 재전송',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 14,
                            fontFamily: 'Cafe24Oneprettynight',
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // 로그인 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              '로그인',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                fontFamily: 'Cafe24Oneprettynight',
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 회원가입 링크
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '계정이 없으신가요? ',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                            fontFamily: 'Cafe24Oneprettynight',
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => EmailSignupScreen(
                                  angelData: widget.angelData,
                                ),
                              ),
                            );
                          },
                          child: Text(
                            '회원가입',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Cafe24Oneprettynight',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputSection({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
            fontFamily: 'Cafe24Oneprettynight',
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Future<void> _resendEmailVerification() async {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('이메일을 입력해주세요.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      final authService = AuthService();
      await authService.sendEmailVerification(_emailController.text.trim());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('인증 이메일을 재전송했습니다. 이메일을 확인해주세요.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('이메일 재전송 실패: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// 비밀번호 재설정 다이얼로그 표시
  void _showPasswordResetDialog() {
    final resetEmailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          '비밀번호 재설정',
          style: TextStyle(
            fontFamily: 'Cafe24Oneprettynight',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '비밀번호 재설정 링크를 보낼 이메일을 입력해주세요.',
              style: TextStyle(fontFamily: 'Cafe24Oneprettynight'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: resetEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'example@gmail.com',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              '취소',
              style: TextStyle(fontFamily: 'Cafe24Oneprettynight'),
            ),
          ),
          TextButton(
            onPressed: () =>
                _handlePasswordReset(resetEmailController.text.trim()),
            child: const Text(
              '전송',
              style: TextStyle(
                fontFamily: 'Cafe24Oneprettynight',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 비밀번호 재설정 처리
  Future<void> _handlePasswordReset(String email) async {
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('이메일을 입력해주세요.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('올바른 이메일 형식을 입력해주세요.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      final authService = AuthService();
      await authService.resetPassword(email);

      if (mounted) {
        Navigator.of(context).pop(); // 다이얼로그 닫기
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('비밀번호 재설정 링크를 이메일로 전송했습니다.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // 다이얼로그 닫기
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('비밀번호 재설정 실패: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
