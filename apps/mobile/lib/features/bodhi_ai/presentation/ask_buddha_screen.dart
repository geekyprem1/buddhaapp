import 'dart:async';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../player/application/audio_providers.dart';
import '../../premium/application/premium_controller.dart';
import '../../premium/application/premium_guard.dart';
import '../application/bodhi_chat_controller.dart';
import '../application/bodhi_chat_store.dart';
import 'widgets/bodhi_message_bubble.dart';
import 'widgets/bodhi_quota_banner.dart';
import 'widgets/bodhi_report_sheet.dart';

/// "Ask Buddha" — the Bodhi AI chat tab.
///
/// Owns the minute-session lifecycle: starts on mount, heartbeats every 20 s
/// while foregrounded, and ends on dispose or when the app is backgrounded, so
/// time only accrues while the user is actually here.
class AskBuddhaScreen extends ConsumerStatefulWidget {
  const AskBuddhaScreen({super.key});

  @override
  ConsumerState<AskBuddhaScreen> createState() => _AskBuddhaScreenState();
}

class _AskBuddhaScreenState extends ConsumerState<AskBuddhaScreen> {
  static const _heartbeat = Duration(seconds: 20);

  final _input = TextEditingController();
  final _scroll = ScrollController();
  Timer? _timer;
  AppLifecycleListener? _lifecycle;

  BodhiChatController get _controller =>
      ref.read(bodhiChatControllerProvider.notifier);

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onResume: _openSession,
      onInactive: _closeSession,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _openSession());
  }

  void _openSession() {
    _timer?.cancel();
    unawaited(_controller.startSession());
    _timer = Timer.periodic(_heartbeat, (_) => _controller.heartbeat());
  }

  void _closeSession() {
    _timer?.cancel();
    _timer = null;
    unawaited(_controller.endSession());
  }

  @override
  void dispose() {
    _closeSession();
    _lifecycle?.dispose();
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    _input.clear();
    final lang = ref.read(currentAppUserProvider).valueOrNull?.language ?? 'en';
    final outcome = await _controller.send(text, lang: lang);
    _scrollToBottom();
    if (!mounted) return;

    final l10n = AppLocalizations.of(context);
    switch (outcome) {
      case BodhiSendOutcome.quotaExhausted:
        // Free users are nudged to the paywall; premium users just see it's
        // out for today.
        final isPremium = ref.read(premiumControllerProvider);
        _snack(l10n?.aiChatQuotaReached ??
            "You've used today's chat time. It resets tomorrow.");
        if (!isPremium) ensurePremium(ref, context);
      case BodhiSendOutcome.disabled:
        _snack(l10n?.aiChatDisabled ?? 'Bodhi AI is currently unavailable.');
      case BodhiSendOutcome.error:
        _snack(l10n?.aiChatError ?? 'Something went wrong. Please try again.');
      case BodhiSendOutcome.ok:
      case BodhiSendOutcome.refused:
        break;
    }
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(bodhiChatControllerProvider);
    // Only reserve clearance for the mini player, which is an overlay. The
    // nav chrome is a Column sibling and already excluded from this body.
    final mediaPlaying =
        ref.watch(currentMediaItemProvider).valueOrNull != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.navAskBuddha ?? 'Ask Buddha'),
        actions: [
          if (state.messages.isNotEmpty)
            IconButton(
              tooltip: l10n?.aiChatClear ?? 'Clear chat',
              onPressed: () => _controller.clear(),
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: Column(
        children: [
          BodhiQuotaBanner(
            remainingSeconds: state.remainingSeconds,
            l10n: l10n,
          ),
          Expanded(
            child: state.messages.isEmpty
                ? _Empty(l10n: l10n, onPick: _fill)
                : ListView.builder(
                    controller: _scroll,
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.md,
                      AppSpacing.md,
                      mediaPlaying ? 72 : AppSpacing.md,
                    ),
                    itemCount: state.messages.length,
                    itemBuilder: (context, i) {
                      final m = state.messages[i];
                      return BodhiMessageBubble(
                        message: m,
                        onReport: m.isUser || m.pending
                            ? null
                            : () => _report(m),
                      );
                    },
                  ),
          ),
          _Composer(
            controller: _input,
            sending: state.sending,
            onSubmit: _submit,
            hint: l10n?.aiChatHint ?? 'Ask about Buddhism…',
          ),
        ],
      ),
    );
  }

  void _fill(String text) {
    _input.text = text;
    _input.selection =
        TextSelection.collapsed(offset: _input.text.length);
  }

  Future<void> _report(BodhiMessage message) async {
    await showBodhiReportSheet(context, ref: ref, reportedText: message.text);
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.l10n, required this.onPick});

  final AppLocalizations? l10n;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    final suggestions = [
      l10n?.aiChatSuggest1 ?? 'What did the Buddha teach about suffering?',
      l10n?.aiChatSuggest2 ?? 'How do I start a daily meditation practice?',
      l10n?.aiChatSuggest3 ?? 'What is the meaning of the Eightfold Path?',
    ];
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        const SizedBox(height: AppSpacing.xl),
        const Icon(Icons.self_improvement, size: 56, color: AppColors.primary),
        const SizedBox(height: AppSpacing.md),
        Text(
          l10n?.aiChatWelcome ?? 'Ask me anything about Buddhism.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          l10n?.aiChatDisclaimer ??
              'Replies are AI-generated and may be inaccurate.',
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.lg),
        for (final s in suggestions)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: OutlinedButton(
              onPressed: () => onPick(s),
              child: Text(s, textAlign: TextAlign.center),
            ),
          ),
      ],
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.sending,
    required this.onSubmit,
    required this.hint,
  });

  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSubmit;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: 8,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.sm,
            AppSpacing.sm,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 5,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => sending ? null : onSubmit(),
                  decoration: InputDecoration(
                    hintText: hint,
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              IconButton.filled(
                onPressed: sending ? null : onSubmit,
                icon: sending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
