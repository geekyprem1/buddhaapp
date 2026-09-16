import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../application/bodhi_chat_store.dart';

/// A single chat bubble. User messages sit right in maroon; assistant messages
/// sit left in surface. A long-press on a settled assistant reply offers the
/// report action (Play generative-AI policy).
class BodhiMessageBubble extends StatelessWidget {
  const BodhiMessageBubble({
    required this.message,
    this.onReport,
    super.key,
  });

  final BodhiMessage message;
  final VoidCallback? onReport;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final scheme = Theme.of(context).colorScheme;
    final bg = isUser ? AppColors.primary : scheme.surface;
    final fg = isUser ? Colors.white : scheme.onSurface;

    final bubble = Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * 0.82,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(isUser ? 16 : 4),
          bottomRight: Radius.circular(isUser ? 4 : 16),
        ),
        border: isUser
            ? null
            : Border.all(color: AppColors.divider),
      ),
      child: message.pending && message.text.isEmpty
          ? const _TypingDots()
          : Text(message.text, style: TextStyle(color: fg, height: 1.35)),
    );

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: onReport,
        child: bubble,
      ),
    );
  }
}

/// Three animated dots shown while the first token is still on its way.
class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 16,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < 3; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: _dot(i),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _dot(int index) {
    // Each dot fades on a staggered phase.
    final phase = (_c.value + index * 0.2) % 1.0;
    final opacity = 0.3 + 0.7 * (1 - (phase * 2 - 1).abs());
    return Opacity(
      opacity: opacity.clamp(0.0, 1.0),
      child: const CircleAvatar(radius: 3, backgroundColor: AppColors.primary),
    );
  }
}
