import 'package:flutter/material.dart';

class StatusBar extends StatelessWidget {
  final String message;
  final bool isListening;
  final bool isTranslating;
  final bool isSpeaking;

  const StatusBar({
    super.key,
    required this.message,
    required this.isListening,
    required this.isTranslating,
    required this.isSpeaking,
  });

  Color _getColor(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (isListening) return cs.errorContainer;
    if (isTranslating) return cs.secondaryContainer;
    if (isSpeaking) return cs.primaryContainer;
    return cs.surfaceVariant;
  }

  Color _getTextColor(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (isListening) return cs.onErrorContainer;
    if (isTranslating) return cs.onSecondaryContainer;
    if (isSpeaking) return cs.onPrimaryContainer;
    return cs.onSurfaceVariant;
  }

  IconData _getIcon() {
    if (isListening) return Icons.mic;
    if (isTranslating) return Icons.translate;
    if (isSpeaking) return Icons.volume_up;
    return Icons.info_outline;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      color: _getColor(context),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          if (isListening || isTranslating || isSpeaking)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: _getTextColor(context),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Icon(_getIcon(), size: 16, color: _getTextColor(context)),
            ),
          Text(
            message,
            style: TextStyle(
              fontSize: 13,
              color: _getTextColor(context),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
