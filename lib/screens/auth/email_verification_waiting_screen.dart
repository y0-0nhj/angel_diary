import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import '../../utils/constants.dart';
import '../../models/angel_data.dart';
import '../../services/deep_link_service.dart';

/// 이메일 인증 대기 화면
///
/// 사용자가 이메일 인증을 완료할 때까지 대기하고,
/// 인증이 완료되면 자동으로 다음 단계로 진행합니다.
class EmailVerificationWaitingScreen extends StatefulWidget {
  final String email;
  final AngelData angelData;

  const EmailVerificationWaitingScreen({
    super.key,
    required this.email,
    required this.angelData,
  });

  @override
  State<EmailVerificationWaitingScreen> createState() =>
      _EmailVerificationWaitingScreenState();
}

class _EmailVerificationWaitingScreenState
    extends State<EmailVerificationWaitingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  Timer? _checkTimer;
  bool _isChecking = false;
  int _secondsElapsed = 0;

  @override
  void initState() {
    super.initState();

    // 애니메이션 설정
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // 딥링크 콜백 설정 (이메일 인증 완료 시 자동으로 화면 닫기)
    DeepLinkService.setOnEmailVerified(() {
      if (mounted) {
        print('✅ 딥링크를 통한 이메일 인증 완료 감지!');
        Navigator.of(context).pop(true);
      }
    });

    // 인증 상태 체크 시작
    _startCheckingVerification();

    // 경과 시간 카운터
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _secondsElapsed++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _checkTimer?.cancel();
    DeepLinkService.clearOnEmailVerified();
    super.dispose();
  }

  /// 주기적으로 이메일 인증 상태를 체크
  void _startCheckingVerification() {
    _checkTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (!mounted || _isChecking) return;

      setState(() {
        _isChecking = true;
      });

      try {
        final supabase = Supabase.instance.client;
        final session = supabase.auth.currentSession;

        if (session != null) {
          final user = session.user;

          // 이메일 인증이 완료되었는지 확인
          if (user.emailConfirmedAt != null) {
            print('✅ 이메일 인증 완료!');
            timer.cancel();

            if (mounted) {
              // 성공 결과와 함께 이전 화면으로 돌아가기
              Navigator.of(context).pop(true);
            }
          }
        }
      } catch (e) {
        print('인증 상태 확인 중 오류: $e');
      } finally {
        if (mounted) {
          setState(() {
            _isChecking = false;
          });
        }
      }
    });
  }

  /// 인증 이메일 재전송
  Future<void> _resendVerificationEmail() async {
    try {
      final supabase = Supabase.instance.client;
      await supabase.auth.resend(type: OtpType.signup, email: widget.email);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('인증 이메일을 다시 보냈습니다!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('이메일 재전송 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // 뒤로가기 버튼을 눌렀을 때 확인 다이얼로그 표시
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('인증을 취소하시겠습니까?'),
            content: const Text('이메일 인증을 완료하지 않으면 회원가입이 완료되지 않습니다.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('계속 기다리기'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('취소'),
              ),
            ],
          ),
        );
        return shouldPop ?? false;
      },
      child: Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 애니메이션 아이콘
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(60),
                    ),
                    child: const Icon(
                      Icons.mark_email_unread_outlined,
                      size: 60,
                      color: primaryColor,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // 제목
                const Text(
                  '이메일을 확인해주세요',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontFamily: 'Cafe24Oneprettynight',
                  ),
                ),

                const SizedBox(height: 16),

                // 이메일 주소 표시
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: cardBgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: primaryColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.email_outlined,
                        size: 20,
                        color: primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.email,
                        style: const TextStyle(
                          fontSize: 16,
                          color: textColor,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Cafe24Oneprettynight',
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 안내 메시지
                const Text(
                  '위 이메일 주소로 인증 링크를 보냈습니다.\n이메일을 확인하고 링크를 클릭해주세요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: textColor,
                    height: 1.5,
                    fontFamily: 'Cafe24Oneprettynight',
                  ),
                ),

                const SizedBox(height: 32),

                // 로딩 인디케이터
                if (_isChecking)
                  const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: primaryColor,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        '인증 확인 중...',
                        style: TextStyle(
                          fontSize: 14,
                          color: textColor,
                          fontFamily: 'Cafe24Oneprettynight',
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 24),

                // 경과 시간 표시
                Text(
                  '대기 시간: ${_formatDuration(_secondsElapsed)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontFamily: 'Cafe24Oneprettynight',
                  ),
                ),

                const SizedBox(height: 32),

                // 이메일 재전송 버튼
                OutlinedButton.icon(
                  onPressed: _resendVerificationEmail,
                  icon: const Icon(Icons.refresh),
                  label: const Text('인증 이메일 다시 보내기'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryColor,
                    side: const BorderSide(color: primaryColor),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 도움말
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('이메일이 오지 않나요?'),
                        content: const Text(
                          '1. 스팸 메일함을 확인해주세요.\n'
                          '2. 이메일 주소가 정확한지 확인해주세요.\n'
                          '3. 몇 분 후에 다시 시도해주세요.\n'
                          '4. "인증 이메일 다시 보내기"를 눌러주세요.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('확인'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text(
                    '이메일이 오지 않나요?',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Cafe24Oneprettynight',
                    ),
                  ),
                ),

                const Spacer(),

                // 취소 버튼
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text(
                    '나중에 인증하기',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontFamily: 'Cafe24Oneprettynight',
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

  /// 경과 시간을 포맷팅
  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
