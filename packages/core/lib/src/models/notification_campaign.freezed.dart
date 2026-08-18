// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_campaign.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

NotificationCampaign _$NotificationCampaignFromJson(Map<String, dynamic> json) {
  return _NotificationCampaign.fromJson(json);
}

/// @nodoc
mixin _$NotificationCampaign {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get body => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;

  /// Deep-link target, e.g. `dhammapath://wallpaper/wp_001`.
  String? get deepLink => throw _privateConstructorUsedError;

  /// One of: `all`, `teacher:{teacherId}`, `language:{code}`,
  /// `platform:{android|ios}`, `user:{uid}`.
  String get audience => throw _privateConstructorUsedError;

  /// draft | scheduled | sent | failed
  String get status => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get scheduledAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get sentAt => throw _privateConstructorUsedError;
  int get deliveredCount => throw _privateConstructorUsedError;
  int get openedCount => throw _privateConstructorUsedError;
  String? get createdBy => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this NotificationCampaign to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NotificationCampaign
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationCampaignCopyWith<NotificationCampaign> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationCampaignCopyWith<$Res> {
  factory $NotificationCampaignCopyWith(NotificationCampaign value,
          $Res Function(NotificationCampaign) then) =
      _$NotificationCampaignCopyWithImpl<$Res, NotificationCampaign>;
  @useResult
  $Res call(
      {String id,
      String title,
      String body,
      String? imageUrl,
      String? deepLink,
      String audience,
      String status,
      @TimestampConverter() DateTime? scheduledAt,
      @TimestampConverter() DateTime? sentAt,
      int deliveredCount,
      int openedCount,
      String? createdBy,
      @TimestampConverter() DateTime? createdAt});
}

/// @nodoc
class _$NotificationCampaignCopyWithImpl<$Res,
        $Val extends NotificationCampaign>
    implements $NotificationCampaignCopyWith<$Res> {
  _$NotificationCampaignCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationCampaign
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? body = null,
    Object? imageUrl = freezed,
    Object? deepLink = freezed,
    Object? audience = null,
    Object? status = null,
    Object? scheduledAt = freezed,
    Object? sentAt = freezed,
    Object? deliveredCount = null,
    Object? openedCount = null,
    Object? createdBy = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      body: null == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      deepLink: freezed == deepLink
          ? _value.deepLink
          : deepLink // ignore: cast_nullable_to_non_nullable
              as String?,
      audience: null == audience
          ? _value.audience
          : audience // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      scheduledAt: freezed == scheduledAt
          ? _value.scheduledAt
          : scheduledAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      sentAt: freezed == sentAt
          ? _value.sentAt
          : sentAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      deliveredCount: null == deliveredCount
          ? _value.deliveredCount
          : deliveredCount // ignore: cast_nullable_to_non_nullable
              as int,
      openedCount: null == openedCount
          ? _value.openedCount
          : openedCount // ignore: cast_nullable_to_non_nullable
              as int,
      createdBy: freezed == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NotificationCampaignImplCopyWith<$Res>
    implements $NotificationCampaignCopyWith<$Res> {
  factory _$$NotificationCampaignImplCopyWith(_$NotificationCampaignImpl value,
          $Res Function(_$NotificationCampaignImpl) then) =
      __$$NotificationCampaignImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String body,
      String? imageUrl,
      String? deepLink,
      String audience,
      String status,
      @TimestampConverter() DateTime? scheduledAt,
      @TimestampConverter() DateTime? sentAt,
      int deliveredCount,
      int openedCount,
      String? createdBy,
      @TimestampConverter() DateTime? createdAt});
}

/// @nodoc
class __$$NotificationCampaignImplCopyWithImpl<$Res>
    extends _$NotificationCampaignCopyWithImpl<$Res, _$NotificationCampaignImpl>
    implements _$$NotificationCampaignImplCopyWith<$Res> {
  __$$NotificationCampaignImplCopyWithImpl(_$NotificationCampaignImpl _value,
      $Res Function(_$NotificationCampaignImpl) _then)
      : super(_value, _then);

  /// Create a copy of NotificationCampaign
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? body = null,
    Object? imageUrl = freezed,
    Object? deepLink = freezed,
    Object? audience = null,
    Object? status = null,
    Object? scheduledAt = freezed,
    Object? sentAt = freezed,
    Object? deliveredCount = null,
    Object? openedCount = null,
    Object? createdBy = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_$NotificationCampaignImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      body: null == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      deepLink: freezed == deepLink
          ? _value.deepLink
          : deepLink // ignore: cast_nullable_to_non_nullable
              as String?,
      audience: null == audience
          ? _value.audience
          : audience // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      scheduledAt: freezed == scheduledAt
          ? _value.scheduledAt
          : scheduledAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      sentAt: freezed == sentAt
          ? _value.sentAt
          : sentAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      deliveredCount: null == deliveredCount
          ? _value.deliveredCount
          : deliveredCount // ignore: cast_nullable_to_non_nullable
              as int,
      openedCount: null == openedCount
          ? _value.openedCount
          : openedCount // ignore: cast_nullable_to_non_nullable
              as int,
      createdBy: freezed == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationCampaignImpl implements _NotificationCampaign {
  const _$NotificationCampaignImpl(
      {required this.id,
      required this.title,
      required this.body,
      this.imageUrl,
      this.deepLink,
      this.audience = 'all',
      this.status = 'draft',
      @TimestampConverter() this.scheduledAt,
      @TimestampConverter() this.sentAt,
      this.deliveredCount = 0,
      this.openedCount = 0,
      this.createdBy,
      @TimestampConverter() this.createdAt});

  factory _$NotificationCampaignImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationCampaignImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String body;
  @override
  final String? imageUrl;

  /// Deep-link target, e.g. `dhammapath://wallpaper/wp_001`.
  @override
  final String? deepLink;

  /// One of: `all`, `teacher:{teacherId}`, `language:{code}`,
  /// `platform:{android|ios}`, `user:{uid}`.
  @override
  @JsonKey()
  final String audience;

  /// draft | scheduled | sent | failed
  @override
  @JsonKey()
  final String status;
  @override
  @TimestampConverter()
  final DateTime? scheduledAt;
  @override
  @TimestampConverter()
  final DateTime? sentAt;
  @override
  @JsonKey()
  final int deliveredCount;
  @override
  @JsonKey()
  final int openedCount;
  @override
  final String? createdBy;
  @override
  @TimestampConverter()
  final DateTime? createdAt;

  @override
  String toString() {
    return 'NotificationCampaign(id: $id, title: $title, body: $body, imageUrl: $imageUrl, deepLink: $deepLink, audience: $audience, status: $status, scheduledAt: $scheduledAt, sentAt: $sentAt, deliveredCount: $deliveredCount, openedCount: $openedCount, createdBy: $createdBy, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationCampaignImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.deepLink, deepLink) ||
                other.deepLink == deepLink) &&
            (identical(other.audience, audience) ||
                other.audience == audience) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.scheduledAt, scheduledAt) ||
                other.scheduledAt == scheduledAt) &&
            (identical(other.sentAt, sentAt) || other.sentAt == sentAt) &&
            (identical(other.deliveredCount, deliveredCount) ||
                other.deliveredCount == deliveredCount) &&
            (identical(other.openedCount, openedCount) ||
                other.openedCount == openedCount) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      body,
      imageUrl,
      deepLink,
      audience,
      status,
      scheduledAt,
      sentAt,
      deliveredCount,
      openedCount,
      createdBy,
      createdAt);

  /// Create a copy of NotificationCampaign
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationCampaignImplCopyWith<_$NotificationCampaignImpl>
      get copyWith =>
          __$$NotificationCampaignImplCopyWithImpl<_$NotificationCampaignImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationCampaignImplToJson(
      this,
    );
  }
}

abstract class _NotificationCampaign implements NotificationCampaign {
  const factory _NotificationCampaign(
          {required final String id,
          required final String title,
          required final String body,
          final String? imageUrl,
          final String? deepLink,
          final String audience,
          final String status,
          @TimestampConverter() final DateTime? scheduledAt,
          @TimestampConverter() final DateTime? sentAt,
          final int deliveredCount,
          final int openedCount,
          final String? createdBy,
          @TimestampConverter() final DateTime? createdAt}) =
      _$NotificationCampaignImpl;

  factory _NotificationCampaign.fromJson(Map<String, dynamic> json) =
      _$NotificationCampaignImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get body;
  @override
  String? get imageUrl;

  /// Deep-link target, e.g. `dhammapath://wallpaper/wp_001`.
  @override
  String? get deepLink;

  /// One of: `all`, `teacher:{teacherId}`, `language:{code}`,
  /// `platform:{android|ios}`, `user:{uid}`.
  @override
  String get audience;

  /// draft | scheduled | sent | failed
  @override
  String get status;
  @override
  @TimestampConverter()
  DateTime? get scheduledAt;
  @override
  @TimestampConverter()
  DateTime? get sentAt;
  @override
  int get deliveredCount;
  @override
  int get openedCount;
  @override
  String? get createdBy;
  @override
  @TimestampConverter()
  DateTime? get createdAt;

  /// Create a copy of NotificationCampaign
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationCampaignImplCopyWith<_$NotificationCampaignImpl>
      get copyWith => throw _privateConstructorUsedError;
}
