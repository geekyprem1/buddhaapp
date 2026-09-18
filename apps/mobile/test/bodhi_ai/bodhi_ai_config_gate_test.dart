import 'dart:async';

import 'package:core/core.dart';
import 'package:dhamma_path/features/bodhi_ai/application/bodhi_chat_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Regression: the Ask Buddha tab stayed hidden forever on a fresh install.
///
/// `config/bodhi_ai` reads require sign-in, and the snapshots listener used
/// to attach before Firebase Auth resolved — PERMISSION_DENIED closed the
/// listener permanently and nothing re-subscribed after login. The provider
/// must not touch Firestore while signed out.
void main() {
  test('signed-out provider emits defaults without touching Firestore',
      () async {
    var watched = 0;
    final container = ProviderContainer(
      overrides: [
        currentAppUserProvider.overrideWith((ref) => Stream.value(null)),
        configRepositoryProvider.overrideWith((ref) => _StubRepo(() {
              watched++;
              return Stream.value(const BodhiAiConfig(enabled: true));
            })),
      ],
    );
    addTearDown(container.dispose);

    final value = await container.read(bodhiAiConfigProvider.future);

    expect(value.enabled, isFalse, reason: 'signed out → disabled default');
    expect(watched, 0, reason: 'signed out must not subscribe to Firestore');
  });

  test('signing in re-subscribes and exposes the live config', () async {
    var watched = 0;
    final userCtrl = StreamController<AppUser?>.broadcast();
    addTearDown(userCtrl.close);

    final container = ProviderContainer(
      overrides: [
        currentAppUserProvider.overrideWith((ref) => userCtrl.stream),
        configRepositoryProvider.overrideWith((ref) => _StubRepo(() {
              watched++;
              return Stream.value(
                const BodhiAiConfig(enabled: true, maxTokens: 300),
              );
            })),
      ],
    );
    addTearDown(container.dispose);

    userCtrl.add(null);
    final sub = container.listen(bodhiAiConfigProvider, (_, __) {});
    addTearDown(sub.close);
    await container.pump();
    expect(watched, 0, reason: 'pre-login must not subscribe');

    userCtrl.add(const AppUser(uid: 'u1'));
    await container.pump();

    final value = await container.read(bodhiAiConfigProvider.future);
    expect(value.enabled, isTrue);
    expect(watched, 1, reason: 'sign-in must attach the live config stream');
  });
}

class _StubRepo implements ConfigRepository {
  _StubRepo(this.onWatch);

  final Stream<BodhiAiConfig> Function() onWatch;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #watchBodhiAiConfig) {
      return onWatch();
    }
    return super.noSuchMethod(invocation);
  }
}
