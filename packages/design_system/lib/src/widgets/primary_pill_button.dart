import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Full-width pill primary button per PRD §10. Disabled state uses the
/// muted-beige [AppColors.disabled] token automatically via [AppTheme].
class PrimaryPillButton extends StatelessWidget {
  const PrimaryPillButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.semanticLabel,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;

    return Semantics(
      label: semanticLabel ?? label,
      button: true,
      enabled: enabled,
      child: SizedBox(
        height: AppSpacing.minTouchTarget,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: enabled ? onPressed : null,
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 20),
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    Text(label),
                  ],
                ),
        ),
      ),
    );
  }
}
