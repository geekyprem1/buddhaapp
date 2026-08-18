// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'content_counters.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ContentCounters _$ContentCountersFromJson(Map<String, dynamic> json) {
  return _ContentCounters.fromJson(json);
}

/// @nodoc
mixin _$ContentCounters {
  int get views => throw _privateConstructorUsedError;
  int get downloads => throw _privateConstructorUsedError;
  int get shares => throw _privateConstructorUsedError;
  int get plays => throw _privateConstructorUsedError;

  /// Serializes this ContentCounters to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ContentCounters
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ContentCountersCopyWith<ContentCounters> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ContentCountersCopyWith<$Res> {
  factory $ContentCountersCopyWith(
          ContentCounters value, $Res Function(ContentCounters) then) =
      _$ContentCountersCopyWithImpl<$Res, ContentCounters>;
  @useResult
  $Res call({int views, int downloads, int shares, int plays});
}

/// @nodoc
class _$ContentCountersCopyWithImpl<$Res, $Val extends ContentCounters>
    implements $ContentCountersCopyWith<$Res> {
  _$ContentCountersCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ContentCounters
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? views = null,
    Object? downloads = null,
    Object? shares = null,
    Object? plays = null,
  }) {
    return _then(_value.copyWith(
      views: null == views
          ? _value.views
          : views // ignore: cast_nullable_to_non_nullable
              as int,
      downloads: null == downloads
          ? _value.downloads
          : downloads // ignore: cast_nullable_to_non_nullable
              as int,
      shares: null == shares
          ? _value.shares
          : shares // ignore: cast_nullable_to_non_nullable
              as int,
      plays: null == plays
          ? _value.plays
          : plays // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ContentCountersImplCopyWith<$Res>
    implements $ContentCountersCopyWith<$Res> {
  factory _$$ContentCountersImplCopyWith(_$ContentCountersImpl value,
          $Res Function(_$ContentCountersImpl) then) =
      __$$ContentCountersImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int views, int downloads, int shares, int plays});
}

/// @nodoc
class __$$ContentCountersImplCopyWithImpl<$Res>
    extends _$ContentCountersCopyWithImpl<$Res, _$ContentCountersImpl>
    implements _$$ContentCountersImplCopyWith<$Res> {
  __$$ContentCountersImplCopyWithImpl(
      _$ContentCountersImpl _value, $Res Function(_$ContentCountersImpl) _then)
      : super(_value, _then);

  /// Create a copy of ContentCounters
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? views = null,
    Object? downloads = null,
    Object? shares = null,
    Object? plays = null,
  }) {
    return _then(_$ContentCountersImpl(
      views: null == views
          ? _value.views
          : views // ignore: cast_nullable_to_non_nullable
              as int,
      downloads: null == downloads
          ? _value.downloads
          : downloads // ignore: cast_nullable_to_non_nullable
              as int,
      shares: null == shares
          ? _value.shares
          : shares // ignore: cast_nullable_to_non_nullable
              as int,
      plays: null == plays
          ? _value.plays
          : plays // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ContentCountersImpl implements _ContentCounters {
  const _$ContentCountersImpl(
      {this.views = 0, this.downloads = 0, this.shares = 0, this.plays = 0});

  factory _$ContentCountersImpl.fromJson(Map<String, dynamic> json) =>
      _$$ContentCountersImplFromJson(json);

  @override
  @JsonKey()
  final int views;
  @override
  @JsonKey()
  final int downloads;
  @override
  @JsonKey()
  final int shares;
  @override
  @JsonKey()
  final int plays;

  @override
  String toString() {
    return 'ContentCounters(views: $views, downloads: $downloads, shares: $shares, plays: $plays)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ContentCountersImpl &&
            (identical(other.views, views) || other.views == views) &&
            (identical(other.downloads, downloads) ||
                other.downloads == downloads) &&
            (identical(other.shares, shares) || other.shares == shares) &&
            (identical(other.plays, plays) || other.plays == plays));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, views, downloads, shares, plays);

  /// Create a copy of ContentCounters
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ContentCountersImplCopyWith<_$ContentCountersImpl> get copyWith =>
      __$$ContentCountersImplCopyWithImpl<_$ContentCountersImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ContentCountersImplToJson(
      this,
    );
  }
}

abstract class _ContentCounters implements ContentCounters {
  const factory _ContentCounters(
      {final int views,
      final int downloads,
      final int shares,
      final int plays}) = _$ContentCountersImpl;

  factory _ContentCounters.fromJson(Map<String, dynamic> json) =
      _$ContentCountersImpl.fromJson;

  @override
  int get views;
  @override
  int get downloads;
  @override
  int get shares;
  @override
  int get plays;

  /// Create a copy of ContentCounters
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ContentCountersImplCopyWith<_$ContentCountersImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
