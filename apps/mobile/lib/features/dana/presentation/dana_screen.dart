import 'dart:io';

import 'package:design_system/design_system.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../wallpaper/application/wallpaper_providers.dart';

/// Daan (Donation & Support) — a voluntary, charitable support page.
///
/// Play policy note: this is deliberately framed as a voluntary charitable
/// donation, NOT a purchase — it unlocks nothing. See [AppLocalizations]
/// `danaDisclaimer`. Payment happens outside the app via the user's own UPI
/// app (scan the QR or copy the UPI id), so no in-app digital goods are sold.
class DanaScreen extends ConsumerStatefulWidget {
  const DanaScreen({super.key});

  /// The receiving UPI address shown on the page and copied by the button.
  static const upiId = 'dhammapath@ptyes';

  static const _qrAsset = 'assets/dana/dana_qr.png';

  @override
  ConsumerState<DanaScreen> createState() => _DanaScreenState();
}

class _DanaScreenState extends ConsumerState<DanaScreen> {
  bool _savingQr = false;

  Future<void> _copyUpi() async {
    final l10n = AppLocalizations.of(context);
    await Clipboard.setData(const ClipboardData(text: DanaScreen.upiId));
    await HapticFeedback.lightImpact();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n?.danaCopied ?? 'UPI ID copied')),
    );
  }

  Future<void> _saveQr() async {
    if (_savingQr) return;
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _savingQr = true);
    try {
      // Write the bundled QR asset to a temp file, then hand it to the
      // existing MediaStore-backed gallery saver used by wallpapers/status.
      final bytes = await rootBundle.load(DanaScreen._qrAsset);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/dhammapath_upi_qr.png');
      await file.writeAsBytes(bytes.buffer.asUint8List(), flush: true);
      await ref.read(wallpaperServiceProvider).saveFileToGallery(file.path);
      await HapticFeedback.lightImpact();
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n?.savedToGallery ?? 'Saved to gallery.')),
      );
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not save the QR.')),
      );
    } finally {
      if (mounted) setState(() => _savingQr = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n?.danaTitle ?? 'Donation & Support')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.xl,
              AppSpacing.md,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n?.danaTagline ?? 'Your support keeps this app alive.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _payCard(context, l10n, theme),
                const SizedBox(height: AppSpacing.lg),
                // Play-policy safe framing: voluntary, unlocks nothing.
                Text(
                  l10n?.danaDisclaimer ??
                      'This is a voluntary charitable donation to support the '
                          'running of this app. It is not a purchase and does '
                          'not unlock any features or content.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  l10n?.danaBlessing ?? 'May all beings be happy',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.primary,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _payCard(
    BuildContext context,
    AppLocalizations? l10n,
    ThemeData theme,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Text(
              l10n?.danaScanPay ?? 'Scan & Pay',
              style: theme.textTheme.titleLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              l10n?.danaAnyUpiApp ?? 'Any UPI app',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // The scannable QR. White background keeps it readable in dark mode.
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: Image.asset(
                DanaScreen._qrAsset,
                width: 220,
                height: 220,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // UPI id row with a Copy affordance.
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n?.danaUpiId ?? 'UPI ID',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DanaScreen.upiId,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _copyUpi,
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    label: Text(l10n?.danaCopy ?? 'Copy'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _savingQr ? null : _saveQr,
                icon: _savingQr
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.download_rounded, size: 18),
                label: Text(l10n?.danaSaveQr ?? 'Save QR'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
