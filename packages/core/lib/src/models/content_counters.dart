import 'package:freezed_annotation/freezed_annotation.dart';

part 'content_counters.freezed.dart';
part 'content_counters.g.dart';

/// Aggregated engagement counters. **Never written directly by clients** —
/// clients append to the `events` collection and the `aggregateEvents`
/// Cloud Function folds them in here (Architecture §8, §6.2 design notes).
@freezed
class ContentCounters with _$ContentCounters {
  const factory ContentCounters({
    @Default(0) int views,
    @Default(0) int downloads,
    @Default(0) int shares,
    @Default(0) int plays,
  }) = _ContentCounters;

  factory ContentCounters.fromJson(Map<String, dynamic> json) =>
      _$ContentCountersFromJson(json);
}
