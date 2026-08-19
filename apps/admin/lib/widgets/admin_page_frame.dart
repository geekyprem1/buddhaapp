import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class AdminPageFrame extends StatelessWidget {
  const AdminPageFrame({
    required this.title,
    required this.child,
    this.actions = const [],
    this.onBack,
    super.key,
  });

  final String title;
  final List<Widget> actions;
  final Widget child;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 24, 32, 16),
            child: Row(
              children: [
                if (onBack != null) ...[
                  IconButton(
                    tooltip: 'Back',
                    onPressed: onBack,
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                ...actions,
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}
