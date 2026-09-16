import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../status/application/status_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Top-left avatar in the Home app bar that opens Profile.
///
/// Profile left the bottom nav (bodhi-ai-chat spec, decision D3), so this is
/// its entry point. It shows, in order of preference: the locally picked
/// status avatar, then the account photo URL, then a person icon.
///
/// Pushes `/profile` (rather than `go`) so a back arrow returns Home.
class ProfileAvatarButton extends ConsumerWidget {
  const ProfileAvatarButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final avatar = ref.watch(statusAvatarProvider);
    final photoUrl = ref.watch(currentAppUserProvider).valueOrNull?.photoUrl;
    final label = l10n?.navProfile ?? 'Profile';

    ImageProvider? image;
    if (avatar != null) {
      image = FileImage(avatar);
    } else if (photoUrl != null && photoUrl.isNotEmpty) {
      image = NetworkImage(photoUrl);
    }

    return Semantics(
      button: true,
      label: label,
      child: IconButton(
        // No tooltip: this widget can render in the Home app bar which always
        // has an Overlay, so a tooltip is safe here — but keep parity with the
        // nav bar's convention and rely on the Semantics label instead.
        onPressed: () => context.push(AppRoutes.profile),
        icon: CircleAvatar(
          radius: 16,
          backgroundColor: AppColors.disabled,
          foregroundImage: image,
          child: image == null
              ? const Icon(Icons.person_outline, size: 18)
              : null,
        ),
      ),
    );
  }
}
