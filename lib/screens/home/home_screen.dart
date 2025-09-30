import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../../common/constants/strings.dart';
import '../../services/audio_service.dart';
import 'tabs/wish_tab.dart';
import 'tabs/goal_tab.dart';
import 'tabs/gratitude_tab.dart';
import 'widgets/background_image.dart';
import 'widgets/inspiration_message.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final AudioService _audioService = AudioService();
  Map<String, String> _currentMessage = AppStrings.inspirationalMessages[0];
  Timer? _messageTimer;
  int _selectedTabIndex = 0;

  void _startMessageRotation() {
    final random = Random();
    _messageTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      setState(() {
        _currentMessage =
            AppStrings.inspirationalMessages[random.nextInt(
              AppStrings.inspirationalMessages.length,
            )];
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeApp();
    _startMessageRotation();
  }

  Future<void> _initializeApp() async {
    await _audioService.initialize();
    // Initialize other services
  }

  @override
  void dispose() {
    _messageTimer?.cancel();
    _audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const BackgroundImage(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: InspirationMessage(message: _currentMessage),
            ),
          ),
          Column(
            children: [
              // Tab bar
              TabBar(
                tabs: [
                  Tab(text: '소망'),
                  Tab(text: '목표'),
                  Tab(text: '감사'),
                ],
              ),
              // Tab content
              Expanded(
                child: TabBarView(
                  children: [WishTab(), GoalTab(), GratitudeTab()],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
