import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/admin_strings.dart';
import '../../../widgets/admin_page_frame.dart';
import '../../../widgets/responsive_layout.dart';
import '../../../widgets/upload_field.dart';
import '../application/premium_config_providers.dart';

/// Admin settings for the premium paywall — currently the promo mp4 shown at
/// the top of the app's premium page.
class PremiumConfigPage extends ConsumerWidget {
  const PremiumConfigPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(adminPremiumConfigProvider);
    return AdminPageFrame(
      title: AdminStrings.premium,
      child: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorState(message: e.toString()),
        data: (config) => ListView(
          padding: AdminResponsive.pagePadding(context, top: 24, bottom: 48),
          children: [
            Text(
              AdminStrings.premiumIntro,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 24),
            Text(
              AdminStrings.premiumVideoField,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            UploadField(
              label: AdminStrings.premiumVideoField,
              valueUrl: config.videoUrl,
              allowedExtensions: FieldValidators.allowedVideoExtensions,
              maxBytes: FieldValidators.maxVideoBytes,
              storagePathBuilder: StoragePaths.premiumVideo,
              onUploaded: (url) {
                ref
                    .read(configRepositoryProvider)
                    .savePremiumConfig(PremiumConfig(videoUrl: url));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text(AdminStrings.saved)),
                );
              },
            ),
            const SizedBox(height: 12),
            Text(
              AdminStrings.premiumVideoHint,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
