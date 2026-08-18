// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$onboardingControllerHash() =>
    r'12eeec6a54e1104439ad94af0045a75745db8b03';

/// Drives the three onboarding steps (PRD FR-3.x, FR-4.x, FR-5.x). Each
/// method writes to Firestore and advances `onboardingStep`, which the
/// router's redirect (app/router.dart) uses to move to the next screen.
///
/// Copied from [OnboardingController].
@ProviderFor(OnboardingController)
final onboardingControllerProvider =
    AutoDisposeAsyncNotifierProvider<OnboardingController, void>.internal(
  OnboardingController.new,
  name: r'onboardingControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$onboardingControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$OnboardingController = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
