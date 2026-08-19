import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/router.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../status/application/status_providers.dart';
import '../application/profile_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(currentAppUserProvider).valueOrNull;
    final avatar = ref.watch(statusAvatarProvider);
    final version = ref.watch(packageInfoProvider).valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(l10n?.profileTitle ?? 'Profile')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Center(
            child: GestureDetector(
              onTap: () => _pickAvatar(context, ref),
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: AppColors.disabled,
                    backgroundImage:
                        avatar != null ? FileImage(avatar) : null,
                    child: avatar == null
                        ? const Icon(Icons.person, size: 48)
                        : null,
                  ),
                  const Positioned(
                    right: 0,
                    bottom: 0,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.primary,
                      child: Icon(Icons.edit, size: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            user?.name.isNotEmpty == true
                ? user!.name
                : (l10n?.statusTapName ?? 'Tap to add name'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          if (user?.phone != null && user!.phone!.isNotEmpty)
            Text(
              '+91 ${user.phone}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          if (user?.email != null && user!.email!.isNotEmpty)
            Text(
              user.email!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          const SizedBox(height: AppSpacing.lg),
          _row(
            icon: Icons.edit_outlined,
            label: l10n?.profileEdit ?? 'Edit Profile',
            onTap: () => context.push(AppRoutes.profileEdit),
          ),
          _row(
            icon: Icons.groups_outlined,
            label: l10n?.profileMyTeachers ?? 'My Teachers',
            onTap: () => context.push(AppRoutes.profileTeachers),
          ),
          _row(
            icon: Icons.badge_outlined,
            label: l10n?.profileMyIdCard ?? 'My ID Card',
            trailing: Text(
              l10n?.profileComingSoon ?? 'Coming soon',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ),
          _row(
            icon: Icons.language,
            label: l10n?.profileChangeLanguage ?? 'Change Language',
            onTap: () => context.push(AppRoutes.profileLanguage),
          ),
          _row(
            icon: Icons.alarm,
            label: l10n?.homeDailyPrarthana ?? 'Daily Prarthana',
            onTap: () => context.push(AppRoutes.prarthana),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.notifications_outlined),
            title: Text(l10n?.profileNotifications ?? 'Notifications'),
            value: user?.notificationPrefs.push ?? true,
            onChanged: user == null
                ? null
                : (v) => ref.read(userRepositoryProvider).setNotificationPrefs(
                      user.uid,
                      user.notificationPrefs.copyWith(push: v),
                    ),
          ),
          _row(
            icon: Icons.info_outline,
            label: l10n?.profileAboutUs ?? 'About Us',
            onTap: () => context.push(
              AppRoutes.profilePage,
              extra: StaticPageSlugs.about,
            ),
          ),
          _row(
            icon: Icons.mail_outline,
            label: l10n?.profileContactUs ?? 'Contact Us',
            onTap: () => context.push(AppRoutes.profileContact),
          ),
          _row(
            icon: Icons.privacy_tip_outlined,
            label: l10n?.profilePrivacyPolicy ?? 'Privacy Policy',
            onTap: () => context.push(
              AppRoutes.profilePage,
              extra: StaticPageSlugs.privacy,
            ),
          ),
          _row(
            icon: Icons.gavel_outlined,
            label: l10n?.profileTermsConditions ?? 'Terms & Conditions',
            onTap: () => context.push(
              AppRoutes.profilePage,
              extra: StaticPageSlugs.terms,
            ),
          ),
          _row(
            icon: Icons.help_outline,
            label: l10n?.profileHelp ?? 'Help',
            onTap: () => context.push(
              AppRoutes.profilePage,
              extra: StaticPageSlugs.help,
            ),
          ),
          _row(
            icon: Icons.star_outline,
            label: l10n?.profileRateUs ?? 'Rate Us',
            onTap: openPlayStore,
          ),
          _row(
            icon: Icons.share,
            label: l10n?.homeShareApp ?? 'Share App',
            onTap: shareApp,
          ),
          _row(
            icon: Icons.logout,
            label: l10n?.profileLogout ?? 'Logout',
            onTap: () => _logout(context, ref),
          ),
          _row(
            icon: Icons.delete_outline,
            label: l10n?.profileDeleteAccount ?? 'Delete Account',
            onTap: () => _delete(context, ref),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            '${l10n?.profileVersion ?? 'Version'} ${version?.version ?? '—'}',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _row({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      enabled: onTap != null,
      onTap: onTap,
    );
  }

  Future<void> _pickAvatar(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n?.statusPickGallery ?? 'Gallery'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(l10n?.statusPickCamera ?? 'Camera'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    await ref.read(statusAvatarProvider.notifier).pick(source: source);
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n?.profileLogout ?? 'Logout'),
        content: Text(
          l10n?.profileLogoutConfirm ?? 'Sign out of Dhamma Path?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n?.ringtonePermissionNotNow ?? 'Not now'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n?.profileLogout ?? 'Logout'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(authServiceProvider).signOut();
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final first = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n?.profileDeleteAccount ?? 'Delete Account'),
        content: Text(
          l10n?.profileDeleteBody ??
              'This requests deletion of your account, alarms and profile. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n?.ringtonePermissionNotNow ?? 'Not now'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n?.profileDeleteContinue ?? 'Continue'),
          ),
        ],
      ),
    );
    if (first != true || !context.mounted) return;
    final second = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n?.profileDeleteConfirmTitle ?? 'Are you sure?'),
        content: Text(
          l10n?.profileDeleteConfirmBody ??
              'Tap Delete again to send the request and sign out.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n?.ringtonePermissionNotNow ?? 'Not now'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n?.profileDeleteAccount ?? 'Delete Account'),
          ),
        ],
      ),
    );
    if (second != true) return;
    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    if (uid != null) {
      await ref.read(userRepositoryProvider).submitDeletionRequest(uid);
    }
    await ref.read(authServiceProvider).signOut();
  }
}
