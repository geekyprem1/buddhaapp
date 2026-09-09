import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../../app/router.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../application/premium_controller.dart';

/// Professional paywall shown when a locked module is opened by a non-premium
/// user. Admin-uploaded promo video on top, benefits, the 3-day trial +
/// ₹199/month plan, Subscribe + Restore, and legal links.
class PremiumScreen extends ConsumerStatefulWidget {
  const PremiumScreen({super.key});

  @override
  ConsumerState<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends ConsumerState<PremiumScreen> {
  VideoPlayerController? _video;
  String? _videoUrl;
  bool _videoLoading = false;
  bool _busy = false;

  @override
  void dispose() {
    _video?.dispose();
    super.dispose();
  }

  void _syncVideo(String? url) {
    if (url == _videoUrl) return;
    _videoUrl = url;
    _video?.dispose();
    _video = null;
    if (url == null || url.isEmpty) {
      _videoLoading = false;
      return;
    }
    _videoLoading = true;
    final c = VideoPlayerController.networkUrl(Uri.parse(url));
    _video = c;
    c.initialize().then((_) {
      if (!mounted) return;
      c
        ..setLooping(true)
        // Promo video plays with sound (unmuted).
        ..setVolume(1)
        ..play();
      setState(() => _videoLoading = false);
    }).catchError((_) {
      if (mounted) setState(() => _videoLoading = false);
    });
  }

  Future<void> _subscribe() async {
    setState(() => _busy = true);
    final started = await ref.read(premiumControllerProvider.notifier).subscribe();
    if (!mounted) return;
    setState(() => _busy = false);
    if (!started) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)?.premiumStoreUnavailable ??
                'Store unavailable. Please try again later.',
          ),
        ),
      );
    }
  }

  Future<void> _restore() async {
    setState(() => _busy = true);
    await ref.read(premiumControllerProvider.notifier).restore();
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)?.premiumRestoreDone ??
              'Restore complete. If you have an active plan it is now active.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // If the user becomes premium (purchase completes), close the paywall.
    ref.listen(premiumControllerProvider, (prev, next) {
      if (next == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n?.premiumThankYou ?? 'You are now Premium. Enjoy!',
            ),
          ),
        );
        if (context.canPop()) context.pop();
      }
    });

    final config = ref.watch(premiumConfigProvider).valueOrNull;
    _syncVideo(config?.videoUrl);
    final video = _video;
    final product = ref.watch(billingServiceProvider).product;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.premiumTitle ?? 'Dhamma Path Premium'),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
        children: [
          // Promo video (admin mp4). Shows a branded loader while it streams
          // in, then the video; falls back to a gradient banner if there's no
          // video / it failed to load.
          AspectRatio(
            aspectRatio: 16 / 9,
            child: (video != null && video.value.isInitialized)
                ? FittedBox(
                    fit: BoxFit.cover,
                    clipBehavior: Clip.hardEdge,
                    child: SizedBox(
                      width: video.value.size.width,
                      height: video.value.size.height,
                      child: VideoPlayer(video),
                    ),
                  )
                : DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [cs.primary, AppColors.accent],
                      ),
                    ),
                    child: Center(
                      child: _videoLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Icon(Icons.workspace_premium,
                              color: Colors.white, size: 56),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n?.premiumHeadline ?? 'Unlock everything',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l10n?.premiumSubhead ??
                      'One plan unlocks all wallpapers, ringtones, songs, '
                          'meditations, chanting, vandana and videos.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _benefits(context, l10n),
                const SizedBox(height: AppSpacing.lg),
                _planCard(context, l10n, theme, product),
                const SizedBox(height: AppSpacing.md),
                PrimaryPillButton(
                  label: l10n?.premiumStartTrial ?? 'Start 3-day free trial',
                  isLoading: _busy,
                  onPressed: _subscribe,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l10n?.premiumTrialNote ??
                      'Free for 3 days, then ₹199/month. Cancel anytime in '
                          'Google Play.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: _busy ? null : _restore,
                  child: Text(l10n?.premiumRestore ?? 'Restore purchases'),
                ),
                const SizedBox(height: AppSpacing.sm),
                _legal(context, l10n, theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _benefits(BuildContext context, AppLocalizations? l10n) {
    final items = <String>[
      l10n?.premiumBenefitWallpapers ?? 'Set unlimited HD wallpapers',
      l10n?.premiumBenefitRingtones ?? 'Set any ringtone',
      l10n?.premiumBenefitAudio ??
          'All songs, meditations, chanting & vandana',
      l10n?.premiumBenefitVideos ?? 'All videos',
      l10n?.premiumBenefitAdFree ?? 'Support the app — ad-free forever',
    ];
    return Column(
      children: [
        for (final t in items)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.check_circle,
                    color: AppColors.success, size: 22),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(t, style: Theme.of(context).textTheme.bodyLarge),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _planCard(
    BuildContext context,
    AppLocalizations? l10n,
    ThemeData theme,
    dynamic product,
  ) {
    // Prefer the store's localized price; fall back to the known price.
    final price = product?.price as String? ?? '₹199';
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            l10n?.premiumPlanName ?? 'Premium Monthly',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
              children: [
                TextSpan(text: price),
                TextSpan(
                  text: l10n?.premiumPerMonth ?? '/month',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n?.premiumTrialBadge ?? '3 days free, then billed monthly',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _legal(BuildContext context, AppLocalizations? l10n, ThemeData theme) {
    final style = theme.textTheme.bodySmall?.copyWith(
      color: AppColors.textSecondary,
    );
    final linkStyle = const TextStyle(
      color: AppColors.primary,
      fontWeight: FontWeight.w700,
    );
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          l10n?.premiumLegalPrefix ?? 'Subscriptions renew automatically. See ',
          style: style,
        ),
        InkWell(
          onTap: () =>
              context.push('${AppRoutes.legal}/${StaticPageSlugs.terms}'),
          child: Text(l10n?.profileTermsConditions ?? 'Terms', style: linkStyle),
        ),
        Text(l10n?.loginLegalAnd ?? ' and ', style: style),
        InkWell(
          onTap: () =>
              context.push('${AppRoutes.legal}/${StaticPageSlugs.privacy}'),
          child: Text(
            l10n?.profilePrivacyPolicy ?? 'Privacy Policy',
            style: linkStyle,
          ),
        ),
        Text('.', style: style),
      ],
    );
  }
}
