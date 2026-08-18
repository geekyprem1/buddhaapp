import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../application/onboarding_controller.dart';

/// Language selection (PRD FR-3.1–3.5): 3 cards, device-locale preselect,
/// red border + check badge on selection, Continue disabled until chosen.
class LanguageScreen extends ConsumerStatefulWidget {
  const LanguageScreen({super.key});

  @override
  ConsumerState<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageOption {
  const _LanguageOption(this.code, this.name, this.native);
  final String code;
  final String name;
  final String native;
}

const _languages = [
  _LanguageOption('en', 'English', 'English'),
  _LanguageOption('hi', 'Hindi', 'हिन्दी'),
  _LanguageOption('mr', 'Marathi', 'मराठी'),
];

class _LanguageScreenState extends ConsumerState<LanguageScreen> {
  String? _selected;

  @override
  void initState() {
    super.initState();
    // Use the binding's dispatcher (context-independent) rather than
    // View.of(context), which triggers an InheritedWidget lookup that is
    // illegal inside initState().
    final deviceLocale =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    _selected = _languages.any((l) => l.code == deviceLocale)
        ? deviceLocale
        : AppConstants.defaultLanguageCode;
  }

  Future<void> _continue() async {
    final code = _selected;
    if (code == null) return;
    await ref.read(onboardingControllerProvider.notifier).selectLanguage(code);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(onboardingControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.lg),
              Text(
                l10n?.languageScreenTitle ?? 'Your Language',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n?.languageScreenSubtitle ?? 'Select your language',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                  childAspectRatio: 1.4,
                  children: [
                    for (final lang in _languages)
                      _LanguageCard(
                        option: lang,
                        selected: _selected == lang.code,
                        onTap: () => setState(() => _selected = lang.code),
                      ),
                  ],
                ),
              ),
              PrimaryPillButton(
                label: l10n?.continueButton ?? 'Continue',
                isLoading: state.isLoading,
                onPressed: _selected == null ? null : _continue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final _LanguageOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${option.name}, ${option.native}',
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.divider,
              width: selected ? 2 : 1,
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      option.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      option.native,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              if (selected)
                const Positioned(
                  top: 8,
                  right: 8,
                  child: CircleAvatar(
                    radius: 10,
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.check, size: 14, color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
