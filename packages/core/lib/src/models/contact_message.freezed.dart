// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'contact_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ContactMessage _$ContactMessageFromJson(Map<String, dynamic> json) {
  return _ContactMessage.fromJson(json);
}

/// @nodoc
mixin _$ContactMessage {
  String get id => throw _privateConstructorUsedError;
  String get uid => throw _privateConstructorUsedError;
  String get subject => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  String? get screenshotUrl => throw _privateConstructorUsedError;

  /// open | resolved
  String get status => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get resolvedAt => throw _privateConstructorUsedError;
  String? get resolvedBy => throw _privateConstructorUsedError;

  /// Serializes this ContactMessage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ContactMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ContactMessageCopyWith<ContactMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ContactMessageCopyWith<$Res> {
  factory $ContactMessageCopyWith(
          ContactMessage value, $Res Function(ContactMessage) then) =
      _$ContactMessageCopyWithImpl<$Res, ContactMessage>;
  @useResult
  $Res call(
      {String id,
      String uid,
      String subject,
      String message,
      String? screenshotUrl,
      String status,
      @TimestampConverter() DateTime? createdAt,
      @TimestampConverter() DateTime? resolvedAt,
      String? resolvedBy});
}

/// @nodoc
class _$ContactMessageCopyWithImpl<$Res, $Val extends ContactMessage>
    implements $ContactMessageCopyWith<$Res> {
  _$ContactMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ContactMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? uid = null,
    Object? subject = null,
    Object? message = null,
    Object? screenshotUrl = freezed,
    Object? status = null,
    Object? createdAt = freezed,
    Object? resolvedAt = freezed,
    Object? resolvedBy = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      uid: null == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      subject: null == subject
          ? _value.subject
          : subject // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      screenshotUrl: freezed == screenshotUrl
          ? _value.screenshotUrl
          : screenshotUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      resolvedAt: freezed == resolvedAt
          ? _value.resolvedAt
          : resolvedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      resolvedBy: freezed == resolvedBy
          ? _value.resolvedBy
          : resolvedBy // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ContactMessageImplCopyWith<$Res>
    implements $ContactMessageCopyWith<$Res> {
  factory _$$ContactMessageImplCopyWith(_$ContactMessageImpl value,
          $Res Function(_$ContactMessageImpl) then) =
      __$$ContactMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String uid,
      String subject,
      String message,
      String? screenshotUrl,
      String status,
      @TimestampConverter() DateTime? createdAt,
      @TimestampConverter() DateTime? resolvedAt,
      String? resolvedBy});
}

/// @nodoc
class __$$ContactMessageImplCopyWithImpl<$Res>
    extends _$ContactMessageCopyWithImpl<$Res, _$ContactMessageImpl>
    implements _$$ContactMessageImplCopyWith<$Res> {
  __$$ContactMessageImplCopyWithImpl(
      _$ContactMessageImpl _value, $Res Function(_$ContactMessageImpl) _then)
      : super(_value, _then);

  /// Create a copy of ContactMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? uid = null,
    Object? subject = null,
    Object? message = null,
    Object? screenshotUrl = freezed,
    Object? status = null,
    Object? createdAt = freezed,
    Object? resolvedAt = freezed,
    Object? resolvedBy = freezed,
  }) {
    return _then(_$ContactMessageImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      uid: null == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      subject: null == subject
          ? _value.subject
          : subject // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      screenshotUrl: freezed == screenshotUrl
          ? _value.screenshotUrl
          : screenshotUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      resolvedAt: freezed == resolvedAt
          ? _value.resolvedAt
          : resolvedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      resolvedBy: freezed == resolvedBy
          ? _value.resolvedBy
          : resolvedBy // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ContactMessageImpl implements _ContactMessage {
  const _$ContactMessageImpl(
      {required this.id,
      required this.uid,
      required this.subject,
      required this.message,
      this.screenshotUrl,
      this.status = 'open',
      @TimestampConverter() this.createdAt,
      @TimestampConverter() this.resolvedAt,
      this.resolvedBy});

  factory _$ContactMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$ContactMessageImplFromJson(json);

  @override
  final String id;
  @override
  final String uid;
  @override
  final String subject;
  @override
  final String message;
  @override
  final String? screenshotUrl;

  /// open | resolved
  @override
  @JsonKey()
  final String status;
  @override
  @TimestampConverter()
  final DateTime? createdAt;
  @override
  @TimestampConverter()
  final DateTime? resolvedAt;
  @override
  final String? resolvedBy;

  @override
  String toString() {
    return 'ContactMessage(id: $id, uid: $uid, subject: $subject, message: $message, screenshotUrl: $screenshotUrl, status: $status, createdAt: $createdAt, resolvedAt: $resolvedAt, resolvedBy: $resolvedBy)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ContactMessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.subject, subject) || other.subject == subject) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.screenshotUrl, screenshotUrl) ||
                other.screenshotUrl == screenshotUrl) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.resolvedAt, resolvedAt) ||
                other.resolvedAt == resolvedAt) &&
            (identical(other.resolvedBy, resolvedBy) ||
                other.resolvedBy == resolvedBy));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, uid, subject, message,
      screenshotUrl, status, createdAt, resolvedAt, resolvedBy);

  /// Create a copy of ContactMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ContactMessageImplCopyWith<_$ContactMessageImpl> get copyWith =>
      __$$ContactMessageImplCopyWithImpl<_$ContactMessageImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ContactMessageImplToJson(
      this,
    );
  }
}

abstract class _ContactMessage implements ContactMessage {
  const factory _ContactMessage(
      {required final String id,
      required final String uid,
      required final String subject,
      required final String message,
      final String? screenshotUrl,
      final String status,
      @TimestampConverter() final DateTime? createdAt,
      @TimestampConverter() final DateTime? resolvedAt,
      final String? resolvedBy}) = _$ContactMessageImpl;

  factory _ContactMessage.fromJson(Map<String, dynamic> json) =
      _$ContactMessageImpl.fromJson;

  @override
  String get id;
  @override
  String get uid;
  @override
  String get subject;
  @override
  String get message;
  @override
  String? get screenshotUrl;

  /// open | resolved
  @override
  String get status;
  @override
  @TimestampConverter()
  DateTime? get createdAt;
  @override
  @TimestampConverter()
  DateTime? get resolvedAt;
  @override
  String? get resolvedBy;

  /// Create a copy of ContactMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ContactMessageImplCopyWith<_$ContactMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
