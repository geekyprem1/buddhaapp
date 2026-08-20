import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../../widgets/brand_header.dart';

/// Branded splash (FR-1.1). The router's redirect (see app/router.dart)
/// owns navigating away from here once auth state and the user profile
/// have resolved — this screen only renders the brand while that happens.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BrandHeader(),
            SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
