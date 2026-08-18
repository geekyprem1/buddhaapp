import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

/// Converts between Firestore [Timestamp] and Dart [DateTime] for
/// json_serializable models. Also tolerates values already decoded as
/// milliseconds-since-epoch (useful in unit tests that build plain maps).
class TimestampConverter implements JsonConverter<DateTime?, Object?> {
  const TimestampConverter();

  @override
  DateTime? fromJson(Object? json) {
    if (json == null) return null;
    if (json is Timestamp) return json.toDate();
    if (json is DateTime) return json;
    if (json is int) return DateTime.fromMillisecondsSinceEpoch(json);
    if (json is String) return DateTime.tryParse(json);
    return null;
  }

  @override
  Object? toJson(DateTime? object) {
    if (object == null) return null;
    return Timestamp.fromDate(object);
  }
}

/// Same as [TimestampConverter] but non-nullable, for required timestamp
/// fields like `createdAt`.
class RequiredTimestampConverter implements JsonConverter<DateTime, Object?> {
  const RequiredTimestampConverter();

  @override
  DateTime fromJson(Object? json) {
    if (json is Timestamp) return json.toDate();
    if (json is DateTime) return json;
    if (json is int) return DateTime.fromMillisecondsSinceEpoch(json);
    if (json is String) {
      final parsed = DateTime.tryParse(json);
      if (parsed != null) return parsed;
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  @override
  Object toJson(DateTime object) => Timestamp.fromDate(object);
}
