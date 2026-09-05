import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'category_filter_providers.g.dart';

/// Active categories for one content module, resolved to chip data
/// (id + localised label) for the category filter row under the teacher
/// row on every content list screen (PRD FR-7.10, FR-10.6).
///
/// Reads the shared `categories` collection (scoped by `module`, active
/// only), so categories created in the admin panel appear in the app
/// automatically — no app release needed.
@riverpod
List<TeacherChipData> moduleCategoryChips(Ref ref, String module) {
  final categories =
      ref.watch(activeCategoriesProvider(module)).valueOrNull ?? const [];
  final user = ref.watch(currentAppUserProvider).valueOrNull;
  final language = user?.language ?? 'en';

  return [
    for (final c in categories)
      TeacherChipData(id: c.id, label: c.name.resolve(language)),
  ];
}

/// The currently-selected category in a content screen's filter row.
/// `null` = "All". Scoped per content module so switching screens doesn't
/// leak filter state between them.
@riverpod
class ContentCategoryFilter extends _$ContentCategoryFilter {
  @override
  String? build(String module) => null;

  void select(String? categoryId) => state = categoryId;
}
