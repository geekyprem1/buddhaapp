import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'video_providers.g.dart';

@riverpod
Stream<List<Video>> adminVideos(Ref ref) {
  return ref.watch(videoRepositoryProvider).watchAll();
}

@riverpod
Future<Video?> adminVideo(Ref ref, String id) {
  return ref.watch(videoRepositoryProvider).getById(id);
}
