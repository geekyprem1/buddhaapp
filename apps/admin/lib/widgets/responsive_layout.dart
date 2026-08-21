import 'package:flutter/material.dart';

enum AdminWindowClass { compact, tablet, desktop }

abstract final class AdminResponsive {
  static const compactBreakpoint = 600.0;
  static const desktopBreakpoint = 1024.0;
  static const expandedNavBreakpoint = 1100.0;

  static AdminWindowClass windowClass(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < compactBreakpoint) return AdminWindowClass.compact;
    if (width < desktopBreakpoint) return AdminWindowClass.tablet;
    return AdminWindowClass.desktop;
  }

  static bool isCompact(BuildContext context) =>
      windowClass(context) == AdminWindowClass.compact;

  static double gutter(BuildContext context) => switch (windowClass(context)) {
        AdminWindowClass.compact => 16,
        AdminWindowClass.tablet => 24,
        AdminWindowClass.desktop => 32,
      };

  static EdgeInsets pagePadding(
    BuildContext context, {
    double top = 16,
    double bottom = 32,
  }) =>
      EdgeInsets.fromLTRB(gutter(context), top, gutter(context), bottom);
}

class ResponsiveFormRow extends StatelessWidget {
  const ResponsiveFormRow({
    required this.children,
    this.spacing = 16,
    this.compactBreakpoint = AdminResponsive.compactBreakpoint,
    super.key,
  });

  final List<Widget> children;
  final double spacing;
  final double compactBreakpoint;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < compactBreakpoint) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  children[i],
                  if (i != children.length - 1) SizedBox(height: spacing),
                ],
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < children.length; i++) ...[
                Expanded(child: children[i]),
                if (i != children.length - 1) SizedBox(width: spacing),
              ],
            ],
          );
        },
      );
}
