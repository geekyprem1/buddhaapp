import 'package:freezed_annotation/freezed_annotation.dart';

import '../utils/timestamp_converter.dart';

part 'contact_message.freezed.dart';
part 'contact_message.g.dart';

/// `contactMessages/{id}` (FR-14.5, AR admin inbox T1.31). Written by the
/// mobile Contact Us form; only admins can read/update (Architecture §7).
@freezed
class ContactMessage with _$ContactMessage {
  const factory ContactMessage({
    required String id,
    required String uid,
    required String subject,
    required String message,
    String? screenshotUrl,

    /// open | resolved
    @Default('open') String status,
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? resolvedAt,
    String? resolvedBy,
  }) = _ContactMessage;

  factory ContactMessage.fromJson(Map<String, dynamic> json) =>
      _$ContactMessageFromJson(json);
}

abstract class ContactMessageStatus {
  ContactMessageStatus._();

  static const open = 'open';
  static const resolved = 'resolved';
}
