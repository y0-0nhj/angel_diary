import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../common/widgets/custom_text_field.dart';
import '../../common/constants/colors.dart';
import '../../models/angel_data.dart';

class EmailSignupScreen extends StatefulWidget {
  final AngelData? angelData;

  const EmailSignupScreen({super.key, this.angelData});

  @override
  State<EmailSignupScreen> createState() => _EmailSignupScreenState();
}

class _EmailSignupScreenState extends State<EmailSignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _birthController = TextEditingController();
  String _selectedGender = '선택';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nicknameController.dispose();
    _birthController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    try {
      // Validate password
      if (_passwordController.text.length < 6) {
        throw 'Password must be at least 6 characters';
      }

      // Create user in Supabase Authentication
      final response = await Supabase.instance.client.auth.signUp(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (response.user == null) throw 'Sign up failed';

      // Store additional user data in Supabase database
      await Supabase.instance.client.from('user_profiles').insert({
        'id': response.user!.id,
        'email': _emailController.text,
        'nickname': _nicknameController.text,
        'birth_date': _birthController.text,
        'gender': _selectedGender,
        'created_at': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        Navigator.of(context).pop(); // Return to previous screen
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('회원가입이 완료되었습니다.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Q1: 이메일
            Text(
              'Q1',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(color: AppColors.text),
            ),
            const SizedBox(height: 8),
            const Text('이메일 주소를 적어주세요.'),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _emailController,
              hintText: 'id@gmail.com',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),

            // Q2: 비밀번호
            Text(
              'Q2',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(color: AppColors.text),
            ),
            const SizedBox(height: 8),
            const Text('비밀번호를 생성해주세요.'),
            const Text(
              '*영문/숫자/특수문자 중 2개 이상 입력하세요.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _passwordController,
              hintText: '비밀번호 입력',
              obscureText: true,
            ),
            const SizedBox(height: 8),
            CustomTextField(hintText: '비밀번호 확인', obscureText: true),
            const SizedBox(height: 24),

            // Q3: 닉네임
            Text(
              'Q3',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(color: AppColors.text),
            ),
            const SizedBox(height: 8),
            const Text('닉네임을 입력해주세요.'),
            const SizedBox(height: 8),
            CustomTextField(controller: _nicknameController, hintText: '해피천사'),
            const SizedBox(height: 24),

            // Q4: 생년월일
            Text(
              'Q4',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(color: AppColors.text),
            ),
            const SizedBox(height: 8),
            const Text('생년월일을 입력해주세요.'),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _birthController,
              hintText: '1900-00-00',
              keyboardType: TextInputType.datetime,
            ),
            const SizedBox(height: 24),

            // Q5: 성별
            Text(
              'Q5',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(color: AppColors.text),
            ),
            const SizedBox(height: 8),
            const Text('성별을 입력해주세요.'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedGender,
                  isExpanded: true,
                  items: ['여자', '남자'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedGender = newValue;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleSignUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  '입력하기',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
