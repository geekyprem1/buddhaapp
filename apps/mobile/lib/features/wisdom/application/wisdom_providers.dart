import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'wisdom_providers.g.dart';

/// Picks one card per calendar day from the active list. Date-seeded
/// (Knuth multiplicative hash), so every user sees the same card all day
/// and consecutive days spread across the list instead of walking it in
/// upload order.
Wisdom? pickWisdomForDate(List<Wisdom> wisdoms, DateTime date) {
  if (wisdoms.isEmpty) return null;
  final dayIndex =
      DateTime(date.year, date.month, date.day).millisecondsSinceEpoch ~/
          Duration.millisecondsPerDay;
  final h = (dayIndex * 2654435761) & 0xFFFFFFFF;
  return wisdoms[h % wisdoms.length];
}

/// Today's card for the home hero. `null` while loading or when the admin
/// hasn't published any card yet (the hero hides itself).
@riverpod
Wisdom? todayWisdom(Ref ref) {
  final wisdoms = ref.watch(activeWisdomsProvider).valueOrNull ?? const [];
  return pickWisdomForDate(wisdoms, DateTime.now());
}

/// One card by id, for the detail screen.
@riverpod
Future<Wisdom?> wisdomById(Ref ref, String id) {
  return ref.watch(wisdomRepositoryProvider).getById(id);
}
