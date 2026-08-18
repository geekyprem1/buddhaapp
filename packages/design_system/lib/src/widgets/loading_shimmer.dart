import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A simple shimmering placeholder box used while list content loads
/// (PRD FR-6.6). Kept dependency-free (no `shimmer` package) — a subtle
/// opacity animation is enough for this app's visual style.
class LoadingShimmer extends StatefulWidget {
  const LoadingShimmer({super.key, this.borderRadius});

  final BorderRadius? borderRadius;

  @override
  State<LoadingShimmer> createState() => _LoadingShimmerState();
}

class _LoadingShimmerState extends State<LoadingShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            color: Color.lerp(
              AppColors.disabled,
              AppColors.divider,
              _controller.value,
            ),
            borderRadius: widget.borderRadius,
          ),
        );
      },
    );
  }
}
