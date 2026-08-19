import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notifications_providers.g.dart';

@riverpod
Stream<List<NotificationCampaign>> adminNotificationCampaigns(Ref ref) {
  return ref.watch(notificationRepositoryProvider).watchAll();
}

@riverpod
Future<NotificationCampaign?> adminNotificationCampaign(Ref ref, String id) {
  return ref.watch(notificationRepositoryProvider).getById(id);
}
