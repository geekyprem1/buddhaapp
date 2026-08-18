// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'audit_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AuditLog _$AuditLogFromJson(Map<String, dynamic> json) {
  return _AuditLog.fromJson(json);
}

/// @nodoc
mixin _$AuditLog {
  String get id => throw _privateConstructorUsedError;
  String get actorUid => throw _privateConstructorUsedError;
  String? get actorEmail => throw _privateConstructorUsedError;

  /// create | update | delete | publish | unpublish | block | unblock
  String get action => throw _privateConstructorUsedError;
  String get entityType => throw _privateConstructorUsedError;
  String get entityId => throw _privateConstructorUsedError;
  Map<String, dynamic>? get before => throw _privateConstructorUsedError;
  Map<String, dynamic>? get after => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this AuditLog to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AuditLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AuditLogCopyWith<AuditLog> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuditLogCopyWith<$Res> {
  factory $AuditLogCopyWith(AuditLog value, $Res Function(AuditLog) then) =
      _$AuditLogCopyWithImpl<$Res, AuditLog>;
  @useResult
  $Res call(
      {String id,
      String actorUid,
      String? actorEmail,
      String action,
      String entityType,
      String entityId,
      Map<String, dynamic>? before,
      Map<String, dynamic>? after,
      @TimestampConverter() DateTime? createdAt});
}

/// @nodoc
class _$AuditLogCopyWithImpl<$Res, $Val extends AuditLog>
    implements $AuditLogCopyWith<$Res> {
  _$AuditLogCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuditLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? actorUid = null,
    Object? actorEmail = freezed,
    Object? action = null,
    Object? entityType = null,
    Object? entityId = null,
    Object? before = freezed,
    Object? after = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      actorUid: null == actorUid
          ? _value.actorUid
          : actorUid // ignore: cast_nullable_to_non_nullable
              as String,
      actorEmail: freezed == actorEmail
          ? _value.actorEmail
          : actorEmail // ignore: cast_nullable_to_non_nullable
              as String?,
      action: null == action
          ? _value.action
          : action // ignore: cast_nullable_to_non_nullable
              as String,
      entityType: null == entityType
          ? _value.entityType
          : entityType // ignore: cast_nullable_to_non_nullable
              as String,
      entityId: null == entityId
          ? _value.entityId
          : entityId // ignore: cast_nullable_to_non_nullable
              as String,
      before: freezed == before
          ? _value.before
          : before // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      after: freezed == after
          ? _value.after
          : after // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AuditLogImplCopyWith<$Res>
    implements $AuditLogCopyWith<$Res> {
  factory _$$AuditLogImplCopyWith(
          _$AuditLogImpl value, $Res Function(_$AuditLogImpl) then) =
      __$$AuditLogImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String actorUid,
      String? actorEmail,
      String action,
      String entityType,
      String entityId,
      Map<String, dynamic>? before,
      Map<String, dynamic>? after,
      @TimestampConverter() DateTime? createdAt});
}

/// @nodoc
class __$$AuditLogImplCopyWithImpl<$Res>
    extends _$AuditLogCopyWithImpl<$Res, _$AuditLogImpl>
    implements _$$AuditLogImplCopyWith<$Res> {
  __$$AuditLogImplCopyWithImpl(
      _$AuditLogImpl _value, $Res Function(_$AuditLogImpl) _then)
      : super(_value, _then);

  /// Create a copy of AuditLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? actorUid = null,
    Object? actorEmail = freezed,
    Object? action = null,
    Object? entityType = null,
    Object? entityId = null,
    Object? before = freezed,
    Object? after = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_$AuditLogImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      actorUid: null == actorUid
          ? _value.actorUid
          : actorUid // ignore: cast_nullable_to_non_nullable
              as String,
      actorEmail: freezed == actorEmail
          ? _value.actorEmail
          : actorEmail // ignore: cast_nullable_to_non_nullable
              as String?,
      action: null == action
          ? _value.action
          : action // ignore: cast_nullable_to_non_nullable
              as String,
      entityType: null == entityType
          ? _value.entityType
          : entityType // ignore: cast_nullable_to_non_nullable
              as String,
      entityId: null == entityId
          ? _value.entityId
          : entityId // ignore: cast_nullable_to_non_nullable
              as String,
      before: freezed == before
          ? _value._before
          : before // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      after: freezed == after
          ? _value._after
          : after // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AuditLogImpl implements _AuditLog {
  const _$AuditLogImpl(
      {required this.id,
      required this.actorUid,
      this.actorEmail,
      required this.action,
      required this.entityType,
      required this.entityId,
      final Map<String, dynamic>? before,
      final Map<String, dynamic>? after,
      @TimestampConverter() this.createdAt})
      : _before = before,
        _after = after;

  factory _$AuditLogImpl.fromJson(Map<String, dynamic> json) =>
      _$$AuditLogImplFromJson(json);

  @override
  final String id;
  @override
  final String actorUid;
  @override
  final String? actorEmail;

  /// create | update | delete | publish | unpublish | block | unblock
  @override
  final String action;
  @override
  final String entityType;
  @override
  final String entityId;
  final Map<String, dynamic>? _before;
  @override
  Map<String, dynamic>? get before {
    final value = _before;
    if (value == null) return null;
    if (_before is EqualUnmodifiableMapView) return _before;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, dynamic>? _after;
  @override
  Map<String, dynamic>? get after {
    final value = _after;
    if (value == null) return null;
    if (_after is EqualUnmodifiableMapView) return _after;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @TimestampConverter()
  final DateTime? createdAt;

  @override
  String toString() {
    return 'AuditLog(id: $id, actorUid: $actorUid, actorEmail: $actorEmail, action: $action, entityType: $entityType, entityId: $entityId, before: $before, after: $after, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuditLogImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.actorUid, actorUid) ||
                other.actorUid == actorUid) &&
            (identical(other.actorEmail, actorEmail) ||
                other.actorEmail == actorEmail) &&
            (identical(other.action, action) || other.action == action) &&
            (identical(other.entityType, entityType) ||
                other.entityType == entityType) &&
            (identical(other.entityId, entityId) ||
                other.entityId == entityId) &&
            const DeepCollectionEquality().equals(other._before, _before) &&
            const DeepCollectionEquality().equals(other._after, _after) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      actorUid,
      actorEmail,
      action,
      entityType,
      entityId,
      const DeepCollectionEquality().hash(_before),
      const DeepCollectionEquality().hash(_after),
      createdAt);

  /// Create a copy of AuditLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuditLogImplCopyWith<_$AuditLogImpl> get copyWith =>
      __$$AuditLogImplCopyWithImpl<_$AuditLogImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AuditLogImplToJson(
      this,
    );
  }
}

abstract class _AuditLog implements AuditLog {
  const factory _AuditLog(
      {required final String id,
      required final String actorUid,
      final String? actorEmail,
      required final String action,
      required final String entityType,
      required final String entityId,
      final Map<String, dynamic>? before,
      final Map<String, dynamic>? after,
      @TimestampConverter() final DateTime? createdAt}) = _$AuditLogImpl;

  factory _AuditLog.fromJson(Map<String, dynamic> json) =
      _$AuditLogImpl.fromJson;

  @override
  String get id;
  @override
  String get actorUid;
  @override
  String? get actorEmail;

  /// create | update | delete | publish | unpublish | block | unblock
  @override
  String get action;
  @override
  String get entityType;
  @override
  String get entityId;
  @override
  Map<String, dynamic>? get before;
  @override
  Map<String, dynamic>? get after;
  @override
  @TimestampConverter()
  DateTime? get createdAt;

  /// Create a copy of AuditLog
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuditLogImplCopyWith<_$AuditLogImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
