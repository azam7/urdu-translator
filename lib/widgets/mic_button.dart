import 'package:flutter/material.dart';

class MicButton extends StatelessWidget {
  final bool isListening;
  final bool isEnabled;
  final AnimationController pulseController;
  final VoidCallback onPressed;

  const MicButton({
    super.key,
    required this.isListening,
    required this.isEnabled,
    required this.pulseController,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: pulseController,
          builder: (_, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // Outer pulse ring (only when listening)
                if (isListening)
                  Container(
                    width: 80 + (pulseController.value * 20),
                    height: 80 + (pulseController.value * 20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.error
                          .withOpacity(0.15 * (1 - pulseController.value)),
                    ),
                  ),
                // Middle pulse ring
                if (isListening)
                  Container(
                    width: 76 + (pulseController.value * 10),
                    height: 76 + (pulseController.value * 10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.error
                          .withOpacity(0.2 * (1 - pulseController.value)),
                    ),
                  ),
                // Main button
                GestureDetector(
                  onTap: isEnabled ? onPressed : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: !isEnabled
                          ? colorScheme.surfaceVariant
                          : isListening
                              ? colorScheme.error
                              : colorScheme.primary,
                      boxShadow: isEnabled
                          ? [
                              BoxShadow(
                                color: (isListening
                                        ? colorScheme.error
                                        : colorScheme.primary)
                                    .withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      isListening ? Icons.stop : Icons.mic,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 6),
        Text(
          isListening ? 'Tap to stop' : 'Tap to speak',
          style: TextStyle(
            fontSize: 11,
            color: isListening
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: isListening ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
