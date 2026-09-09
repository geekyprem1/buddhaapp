import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_banner_providers.g.dart';

@riverpod
Stream<List<HomeBanner>> adminHomeBanners(Ref ref) {
  return ref.watch(homeBannerRepositoryProvider).watchAll();
}

@riverpod
Future<HomeBanner?> adminHomeBanner(Ref ref, String id) {
  return ref.watch(homeBannerRepositoryProvider).getById(id);
}
