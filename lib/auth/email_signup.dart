import 'package:angel_diary/main.dart';
import 'package:angel_diary/auth/email_signup.dart';
import 'package:flutter/material.dart';

class EmailSignup extends StatefulWidget {
  const EmailSignup({super.key});
  @override
  State<EmailSignup> createState() => _EmailSignupState();
}


class _EmailSignupState extends State<EmailSignup> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildPage(0),
    );
  }
}

Widget buildPage(int idx) {
  switch (idx) {
    case 0: return _buildQ1();
    default: return Container();
  }
}


// Q1: 이메일
Widget _buildQ1() {
  return Padding( 
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBackArrow(),
                const SizedBox(height: 8),
                const Text('Q1', style: TextStyle(fontSize: 60)),
                const Text('이메일을 입력해주세요', style: TextStyle(fontSize: 30)),
                const SizedBox(height: 20),
                TextField(
                  style: TextStyle(fontSize: 30),
                  decoration: InputDecoration(
                    hintText: '@example.com',
                    hintStyle: TextStyle(fontSize: 30),
                  ),
                ),
                const SizedBox(height: 20),



        const SizedBox(height: 16),
        Center(
          child: _buildButton('확인', () {}),
        ),
      ],
      ),
    ),
      ),
  ]),
  );
}

  Widget _buildBackArrow() {
    return IconButton(
      icon: Image.asset('assets/icons/arrow_left2.png', width: 50, height: 50),
      onPressed: () {},
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    );
  }



  Widget _buildButton(String text, VoidCallback? onTap) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 0,
        ),
        onPressed: onTap, 
        child: Text(
          text,
          style: TextStyle(fontSize: 22, color: Colors.white),
        ),
      ),
    );
  }

