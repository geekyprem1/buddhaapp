import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'teachers_providers.g.dart';

@riverpod
Stream<List<Teacher>> adminTeachers(Ref ref) {
  return ref.watch(teacherRepositoryProvider).watchAll();
}

@riverpod
Future<Teacher?> adminTeacher(Ref ref, String id) {
  return ref.watch(teacherRepositoryProvider).getById(id);
}
