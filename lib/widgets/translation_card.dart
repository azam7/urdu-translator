import 'package:flutter/material.dart';

class TranslationCard extends StatelessWidget {
  final String label;
  final IconData labelIcon;
  final String text;
  final String placeholder;
  final bool isPartial;
  final TextAlign textAlign;
  final Color accentColor;
  final VoidCallback onCopy;
  final bool showSpeakButton;
  final bool isSpeaking;
  final VoidCallback? onSpeak;

  const TranslationCard({
    super.key,
    required this.label,
    required this.labelIcon,
    required this.text,
    required this.placeholder,
    required this.onCopy,
    required this.accentColor,
    this.isPartial = false,
    this.textAlign = TextAlign.left,
    this.showSpeakButton = false,
    this.isSpeaking = false,
    this.onSpeak,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isEmpty = text.isEmpty;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 120),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isEmpty
              ? colorScheme.outlineVariant
              : accentColor.withOpacity(0.4),
          width: isEmpty ? 0.5 : 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.06),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                Icon(labelIcon, size: 16, color: accentColor),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: accentColor,
                    letterSpacing: 0.3,
                  ),
                ),
                const Spacer(),
                // Speak button
                if (showSpeakButton && onSpeak != null)
                  InkWell(
                    onTap: isSpeaking ? null : onSpeak,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        isSpeaking ? Icons.volume_up : Icons.play_circle_outline,
                        size: 20,
                        color: isSpeaking ? accentColor : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                const SizedBox(width: 4),
                // Copy button
                InkWell(
                  onTap: isEmpty ? null : onCopy,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.copy_outlined,
                      size: 18,
                      color: isEmpty
                          ? colorScheme.outlineVariant
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Text content
          Padding(
            padding: const EdgeInsets.all(14),
            child: isEmpty
                ? Text(
                    placeholder,
                    textAlign: textAlign,
                    style: TextStyle(
                      fontSize: 15,
                      color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                      fontStyle: FontStyle.italic,
                    ),
                  )
                : Text(
                    text,
                    textAlign: textAlign,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: isPartial
                          ? colorScheme.onSurface.withOpacity(0.6)
                          : colorScheme.onSurface,
                      height: 1.5,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
