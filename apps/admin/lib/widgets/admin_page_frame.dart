import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import 'responsive_layout.dart';

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
            padding: AdminResponsive.pagePadding(
              context,
              top: AdminResponsive.isCompact(context) ? 12 : 24,
              bottom: 16,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = AdminResponsive.isCompact(context);
                final stackActions = compact || constraints.maxWidth < 720;
                final heading = Row(
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
                        maxLines: compact ? 2 : 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                    ),
                    if (!stackActions) ...actions,
                  ],
                );
                if (!stackActions || actions.isEmpty) return heading;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    heading,
                    const SizedBox(height: 12),
                    Wrap(
                      alignment: WrapAlignment.end,
                      spacing: 8,
                      runSpacing: 8,
                      children: actions,
                    ),
                  ],
                );
              },
            ),
          ),
          const Divider(height: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}
