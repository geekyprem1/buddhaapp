import 'dart:async';

import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'onboarding_controller.g.dart';

/// Drives the three onboarding steps (PRD FR-3.x, FR-4.x, FR-5.x). Each
/// method writes to Firestore and advances `onboardingStep`, which the
/// router's redirect (app/router.dart) uses to move to the next screen.
@riverpod
class OnboardingController extends _$OnboardingController {
  @override
  FutureOr<void> build() {}

  String get _uid {
    final uid = ref.read(authServiceProvider).currentUser?.uid;
    if (uid == null) {
      throw StateError('OnboardingController used while signed out');
    }
    return uid;
  }

  Future<void> selectLanguage(String languageCode) async {
    state = const AsyncLoading();
    try {
      await ref.read(userRepositoryProvider).updateLanguage(_uid, languageCode);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> submitPersonInfo({
    required String name,
    required String phone,
    String? email,
  }) async {
    state = const AsyncLoading();
    try {
      await ref
          .read(userRepositoryProvider)
          .updatePersonInfo(_uid, name: name, phone: phone, email: email);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> submitTeachers(List<String> teacherIds) async {
    state = const AsyncLoading();
    try {
      await ref
          .read(userRepositoryProvider)
          .updateSelectedTeachers(_uid, teacherIds);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
