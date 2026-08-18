// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'alarm.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Alarm _$AlarmFromJson(Map<String, dynamic> json) {
  return _Alarm.fromJson(json);
}

/// @nodoc
mixin _$Alarm {
  String get id => throw _privateConstructorUsedError;
  int get timeHour => throw _privateConstructorUsedError;
  int get timeMinute => throw _privateConstructorUsedError;

  /// ISO weekday numbers (1 = Monday .. 7 = Sunday). Empty = one-shot.
  List<int> get repeatDays => throw _privateConstructorUsedError;
  bool get isEveryday => throw _privateConstructorUsedError;
  String? get prarthanaId => throw _privateConstructorUsedError;

  /// Path to the pre-downloaded audio file — required before the alarm
  /// can be considered "set" (PRD FR-11.8).
  String? get prarthanaLocalPath => throw _privateConstructorUsedError;
  bool get isEnabled => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;
  int get snoozeMinutes => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Alarm to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Alarm
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AlarmCopyWith<Alarm> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AlarmCopyWith<$Res> {
  factory $AlarmCopyWith(Alarm value, $Res Function(Alarm) then) =
      _$AlarmCopyWithImpl<$Res, Alarm>;
  @useResult
  $Res call(
      {String id,
      int timeHour,
      int timeMinute,
      List<int> repeatDays,
      bool isEveryday,
      String? prarthanaId,
      String? prarthanaLocalPath,
      bool isEnabled,
      String label,
      int snoozeMinutes,
      @TimestampConverter() DateTime? createdAt});
}

/// @nodoc
class _$AlarmCopyWithImpl<$Res, $Val extends Alarm>
    implements $AlarmCopyWith<$Res> {
  _$AlarmCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Alarm
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? timeHour = null,
    Object? timeMinute = null,
    Object? repeatDays = null,
    Object? isEveryday = null,
    Object? prarthanaId = freezed,
    Object? prarthanaLocalPath = freezed,
    Object? isEnabled = null,
    Object? label = null,
    Object? snoozeMinutes = null,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      timeHour: null == timeHour
          ? _value.timeHour
          : timeHour // ignore: cast_nullable_to_non_nullable
              as int,
      timeMinute: null == timeMinute
          ? _value.timeMinute
          : timeMinute // ignore: cast_nullable_to_non_nullable
              as int,
      repeatDays: null == repeatDays
          ? _value.repeatDays
          : repeatDays // ignore: cast_nullable_to_non_nullable
              as List<int>,
      isEveryday: null == isEveryday
          ? _value.isEveryday
          : isEveryday // ignore: cast_nullable_to_non_nullable
              as bool,
      prarthanaId: freezed == prarthanaId
          ? _value.prarthanaId
          : prarthanaId // ignore: cast_nullable_to_non_nullable
              as String?,
      prarthanaLocalPath: freezed == prarthanaLocalPath
          ? _value.prarthanaLocalPath
          : prarthanaLocalPath // ignore: cast_nullable_to_non_nullable
              as String?,
      isEnabled: null == isEnabled
          ? _value.isEnabled
          : isEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      snoozeMinutes: null == snoozeMinutes
          ? _value.snoozeMinutes
          : snoozeMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AlarmImplCopyWith<$Res> implements $AlarmCopyWith<$Res> {
  factory _$$AlarmImplCopyWith(
          _$AlarmImpl value, $Res Function(_$AlarmImpl) then) =
      __$$AlarmImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      int timeHour,
      int timeMinute,
      List<int> repeatDays,
      bool isEveryday,
      String? prarthanaId,
      String? prarthanaLocalPath,
      bool isEnabled,
      String label,
      int snoozeMinutes,
      @TimestampConverter() DateTime? createdAt});
}

/// @nodoc
class __$$AlarmImplCopyWithImpl<$Res>
    extends _$AlarmCopyWithImpl<$Res, _$AlarmImpl>
    implements _$$AlarmImplCopyWith<$Res> {
  __$$AlarmImplCopyWithImpl(
      _$AlarmImpl _value, $Res Function(_$AlarmImpl) _then)
      : super(_value, _then);

  /// Create a copy of Alarm
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? timeHour = null,
    Object? timeMinute = null,
    Object? repeatDays = null,
    Object? isEveryday = null,
    Object? prarthanaId = freezed,
    Object? prarthanaLocalPath = freezed,
    Object? isEnabled = null,
    Object? label = null,
    Object? snoozeMinutes = null,
    Object? createdAt = freezed,
  }) {
    return _then(_$AlarmImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      timeHour: null == timeHour
          ? _value.timeHour
          : timeHour // ignore: cast_nullable_to_non_nullable
              as int,
      timeMinute: null == timeMinute
          ? _value.timeMinute
          : timeMinute // ignore: cast_nullable_to_non_nullable
              as int,
      repeatDays: null == repeatDays
          ? _value._repeatDays
          : repeatDays // ignore: cast_nullable_to_non_nullable
              as List<int>,
      isEveryday: null == isEveryday
          ? _value.isEveryday
          : isEveryday // ignore: cast_nullable_to_non_nullable
              as bool,
      prarthanaId: freezed == prarthanaId
          ? _value.prarthanaId
          : prarthanaId // ignore: cast_nullable_to_non_nullable
              as String?,
      prarthanaLocalPath: freezed == prarthanaLocalPath
          ? _value.prarthanaLocalPath
          : prarthanaLocalPath // ignore: cast_nullable_to_non_nullable
              as String?,
      isEnabled: null == isEnabled
          ? _value.isEnabled
          : isEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      snoozeMinutes: null == snoozeMinutes
          ? _value.snoozeMinutes
          : snoozeMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AlarmImpl implements _Alarm {
  const _$AlarmImpl(
      {required this.id,
      this.timeHour = 6,
      this.timeMinute = 0,
      final List<int> repeatDays = const <int>[],
      this.isEveryday = true,
      this.prarthanaId,
      this.prarthanaLocalPath,
      this.isEnabled = true,
      this.label = 'Daily Prarthana',
      this.snoozeMinutes = 10,
      @TimestampConverter() this.createdAt})
      : _repeatDays = repeatDays;

  factory _$AlarmImpl.fromJson(Map<String, dynamic> json) =>
      _$$AlarmImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey()
  final int timeHour;
  @override
  @JsonKey()
  final int timeMinute;

  /// ISO weekday numbers (1 = Monday .. 7 = Sunday). Empty = one-shot.
  final List<int> _repeatDays;

  /// ISO weekday numbers (1 = Monday .. 7 = Sunday). Empty = one-shot.
  @override
  @JsonKey()
  List<int> get repeatDays {
    if (_repeatDays is EqualUnmodifiableListView) return _repeatDays;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_repeatDays);
  }

  @override
  @JsonKey()
  final bool isEveryday;
  @override
  final String? prarthanaId;

  /// Path to the pre-downloaded audio file — required before the alarm
  /// can be considered "set" (PRD FR-11.8).
  @override
  final String? prarthanaLocalPath;
  @override
  @JsonKey()
  final bool isEnabled;
  @override
  @JsonKey()
  final String label;
  @override
  @JsonKey()
  final int snoozeMinutes;
  @override
  @TimestampConverter()
  final DateTime? createdAt;

  @override
  String toString() {
    return 'Alarm(id: $id, timeHour: $timeHour, timeMinute: $timeMinute, repeatDays: $repeatDays, isEveryday: $isEveryday, prarthanaId: $prarthanaId, prarthanaLocalPath: $prarthanaLocalPath, isEnabled: $isEnabled, label: $label, snoozeMinutes: $snoozeMinutes, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AlarmImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.timeHour, timeHour) ||
                other.timeHour == timeHour) &&
            (identical(other.timeMinute, timeMinute) ||
                other.timeMinute == timeMinute) &&
            const DeepCollectionEquality()
                .equals(other._repeatDays, _repeatDays) &&
            (identical(other.isEveryday, isEveryday) ||
                other.isEveryday == isEveryday) &&
            (identical(other.prarthanaId, prarthanaId) ||
                other.prarthanaId == prarthanaId) &&
            (identical(other.prarthanaLocalPath, prarthanaLocalPath) ||
                other.prarthanaLocalPath == prarthanaLocalPath) &&
            (identical(other.isEnabled, isEnabled) ||
                other.isEnabled == isEnabled) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.snoozeMinutes, snoozeMinutes) ||
                other.snoozeMinutes == snoozeMinutes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      timeHour,
      timeMinute,
      const DeepCollectionEquality().hash(_repeatDays),
      isEveryday,
      prarthanaId,
      prarthanaLocalPath,
      isEnabled,
      label,
      snoozeMinutes,
      createdAt);

  /// Create a copy of Alarm
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AlarmImplCopyWith<_$AlarmImpl> get copyWith =>
      __$$AlarmImplCopyWithImpl<_$AlarmImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AlarmImplToJson(
      this,
    );
  }
}

abstract class _Alarm implements Alarm {
  const factory _Alarm(
      {required final String id,
      final int timeHour,
      final int timeMinute,
      final List<int> repeatDays,
      final bool isEveryday,
      final String? prarthanaId,
      final String? prarthanaLocalPath,
      final bool isEnabled,
      final String label,
      final int snoozeMinutes,
      @TimestampConverter() final DateTime? createdAt}) = _$AlarmImpl;

  factory _Alarm.fromJson(Map<String, dynamic> json) = _$AlarmImpl.fromJson;

  @override
  String get id;
  @override
  int get timeHour;
  @override
  int get timeMinute;

  /// ISO weekday numbers (1 = Monday .. 7 = Sunday). Empty = one-shot.
  @override
  List<int> get repeatDays;
  @override
  bool get isEveryday;
  @override
  String? get prarthanaId;

  /// Path to the pre-downloaded audio file — required before the alarm
  /// can be considered "set" (PRD FR-11.8).
  @override
  String? get prarthanaLocalPath;
  @override
  bool get isEnabled;
  @override
  String get label;
  @override
  int get snoozeMinutes;
  @override
  @TimestampConverter()
  DateTime? get createdAt;

  /// Create a copy of Alarm
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AlarmImplCopyWith<_$AlarmImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
