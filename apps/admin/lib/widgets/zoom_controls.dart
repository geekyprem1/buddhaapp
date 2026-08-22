import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/admin_strings.dart';
import '../features/accessibility/application/zoom_controller.dart';

/// Compact A− / percentage / A+ cluster for the top bar so low-vision
/// editors can enlarge all desk text (WCAG 1.4.4). The percentage acts as a
/// reset button.
class ZoomControls extends ConsumerWidget {
  const ZoomControls({this.compact = false, super.key});

  /// On narrow screens we drop the percentage label to save room.
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zoom = ref.watch(zoomControllerProvider);
    final controller = ref.read(zoomControllerProvider.notifier);
    final percent = '${(zoom * 100).round()}%';

    return Semantics(
      container: true,
      label: '${AdminStrings.zoom}: $percent',
      child: Tooltip(
        message: AdminStrings.zoomTooltip,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.accent),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ZoomButton(
                icon: Icons.text_decrease,
                tooltip: AdminStrings.zoomOut,
                onPressed: controller.canDecrease ? controller.decrease : null,
              ),
              if (!compact)
                InkWell(
                  onTap: controller.reset,
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    child: Text(
                      percent,
                      // Keep the readout at a fixed size regardless of the
                      // active zoom so the control never grows out of the bar.
                      textScaler: TextScaler.noScaling,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontFeatures: const [
                              FontFeature.tabularFigures(),
                            ],
                          ),
                    ),
                  ),
                ),
              _ZoomButton(
                icon: Icons.text_increase,
                tooltip: AdminStrings.zoomIn,
                onPressed: controller.canIncrease ? controller.increase : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ZoomButton extends StatelessWidget {
  const _ZoomButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      iconSize: 20,
      color: AppColors.primary,
      disabledColor: AppColors.textSecondary,
      icon: Icon(icon),
    );
  }
}
