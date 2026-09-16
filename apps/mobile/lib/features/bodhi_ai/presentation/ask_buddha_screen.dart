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
/// Owns the minute-session lifecycle: a session is open only while this tab is
/// actually visible (its branch selected and no route pushed on top) AND the
/// app is foregrounded, with a heartbeat every 20 s in between — so time only
/// accrues while the user is really here.
class AskBuddhaScreen extends ConsumerStatefulWidget {
  const AskBuddhaScreen({super.key});

  @override
  ConsumerState<AskBuddhaScreen> createState() => _AskBuddhaScreenState();
}

class _AskBuddhaScreenState extends ConsumerState<AskBuddhaScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();

  BodhiChatController get _controller =>
      ref.read(bodhiChatControllerProvider.notifier);

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_trackBottom);
    // Populate the counter on open. Nothing else to do on the lifecycle: the
    // quota is charged per message, so there is no session to open, tick or
    // close, and no reason to care whether this tab is foregrounded.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.refreshQuota();
    });
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.removeListener(_trackBottom);
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
    // The controller drops failed turns from the transcript (A8); put the
    // question back in the composer so the user can retry instead of
    // retyping. Refusals already have an answer bubble, so they restore
    // nothing.
    final failed = outcome == BodhiSendOutcome.quotaExhausted ||
        outcome == BodhiSendOutcome.disabled ||
        outcome == BodhiSendOutcome.error;
    if (failed) _fill(text);

    switch (outcome) {
      case BodhiSendOutcome.quotaExhausted:
        // Free users are nudged to the paywall (premium raises the daily cap);
        // premium users just see that they are out for today. The nudge waits
        // for entitlement resolution (A16) so a paid user in the cold-start
        // window never sees the paywall.
        {
          final isPremium = ref.read(premiumControllerProvider);
          final premiumReady = ref.read(premiumReadyProvider);
          _snack(l10n?.aiChatQuotaReached ??
              "You've used today's messages. It resets tomorrow.");
          if (!isPremium && premiumReady) ensurePremium(ref, context);
        }
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

  /// Whether the user was near the bottom BEFORE the latest content arrived
  /// (C3). A large insert grows `maxScrollExtent` past the old position, so a
  /// live near-bottom check would wrongly fail for a user who never scrolled
  /// away — this latch is updated on actual scroll activity instead.
  bool _wasAtBottom = true;

  void _trackBottom() {
    if (!_scroll.hasClients) return;
    final pos = _scroll.position;
    _wasAtBottom = pos.pixels >= pos.maxScrollExtent - 200;
  }

  /// Follows the streaming reply (C3), but only while the user never left
  /// the bottom — never yanks them away from reading history.
  void _followStream() {
    if (!_wasAtBottom || !_scroll.hasClients) return;
    _scroll.animateTo(
      _scroll.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(bodhiChatControllerProvider);
    // Follow-up to every chat state change (deltas included); the follow
    // itself is post-frame and near-bottom-guarded.
    ref.listen(bodhiChatControllerProvider, (_, __) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _followStream());
    });
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
            remainingMessages: state.remainingMessages,
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
