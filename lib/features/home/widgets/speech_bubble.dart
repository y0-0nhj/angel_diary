import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../features/angel/models/angel_model.dart';
import '../../../utils/constants.dart';

class SpeechBubble extends StatelessWidget {
  final Angel? angelData;

  const SpeechBubble({super.key, this.angelData});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final angelName = angelData?.name ?? '천사';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _buildMessageText(context, angelData, angelName),
              style: const TextStyle(
                fontSize: 18,
                color: textColor,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Text('😊', style: TextStyle(fontSize: 30)),
        ],
      ),
    );
  }

  String _buildMessageText(BuildContext context, Angel? angelData, String angelName) {
    final l10n = AppLocalizations.of(context)!;
    final random = Random();
    
    // 격려 메시지 배열
    final messages = [
      {'text': l10n.inspirationalMessage1, 'source': l10n.source1},
      {'text': l10n.inspirationalMessage2, 'source': l10n.source2},
      {'text': l10n.inspirationalMessage3, 'source': l10n.source3},
      {'text': l10n.inspirationalMessage4, 'source': l10n.source4},
    ];
    
    final message = messages[random.nextInt(messages.length)];

    final greeting = angelData != null
        ? l10n.angelGreeting(angelName)
        : l10n.defaultGreeting;

    return '$greeting\n\n${message['text']}\n- ${message['source']}';
  }
}
