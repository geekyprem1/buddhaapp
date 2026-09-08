import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'place_providers.g.dart';

@riverpod
Stream<List<BuddhistPlace>> adminPlaces(Ref ref) {
  return ref.watch(placeRepositoryProvider).watchAll();
}

@riverpod
Future<BuddhistPlace?> adminPlace(Ref ref, String id) {
  return ref.watch(placeRepositoryProvider).getById(id);
}
