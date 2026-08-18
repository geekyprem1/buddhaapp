// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'content_type_metas.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

WallpaperMeta _$WallpaperMetaFromJson(Map<String, dynamic> json) {
  return _WallpaperMeta.fromJson(json);
}

/// @nodoc
mixin _$WallpaperMeta {
  String get kind => throw _privateConstructorUsedError;
  int? get width => throw _privateConstructorUsedError;
  int? get height => throw _privateConstructorUsedError;
  String get orientation => throw _privateConstructorUsedError;

  /// Serializes this WallpaperMeta to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WallpaperMeta
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WallpaperMetaCopyWith<WallpaperMeta> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WallpaperMetaCopyWith<$Res> {
  factory $WallpaperMetaCopyWith(
          WallpaperMeta value, $Res Function(WallpaperMeta) then) =
      _$WallpaperMetaCopyWithImpl<$Res, WallpaperMeta>;
  @useResult
  $Res call({String kind, int? width, int? height, String orientation});
}

/// @nodoc
class _$WallpaperMetaCopyWithImpl<$Res, $Val extends WallpaperMeta>
    implements $WallpaperMetaCopyWith<$Res> {
  _$WallpaperMetaCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WallpaperMeta
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? kind = null,
    Object? width = freezed,
    Object? height = freezed,
    Object? orientation = null,
  }) {
    return _then(_value.copyWith(
      kind: null == kind
          ? _value.kind
          : kind // ignore: cast_nullable_to_non_nullable
              as String,
      width: freezed == width
          ? _value.width
          : width // ignore: cast_nullable_to_non_nullable
              as int?,
      height: freezed == height
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as int?,
      orientation: null == orientation
          ? _value.orientation
          : orientation // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WallpaperMetaImplCopyWith<$Res>
    implements $WallpaperMetaCopyWith<$Res> {
  factory _$$WallpaperMetaImplCopyWith(
          _$WallpaperMetaImpl value, $Res Function(_$WallpaperMetaImpl) then) =
      __$$WallpaperMetaImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String kind, int? width, int? height, String orientation});
}

/// @nodoc
class __$$WallpaperMetaImplCopyWithImpl<$Res>
    extends _$WallpaperMetaCopyWithImpl<$Res, _$WallpaperMetaImpl>
    implements _$$WallpaperMetaImplCopyWith<$Res> {
  __$$WallpaperMetaImplCopyWithImpl(
      _$WallpaperMetaImpl _value, $Res Function(_$WallpaperMetaImpl) _then)
      : super(_value, _then);

  /// Create a copy of WallpaperMeta
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? kind = null,
    Object? width = freezed,
    Object? height = freezed,
    Object? orientation = null,
  }) {
    return _then(_$WallpaperMetaImpl(
      kind: null == kind
          ? _value.kind
          : kind // ignore: cast_nullable_to_non_nullable
              as String,
      width: freezed == width
          ? _value.width
          : width // ignore: cast_nullable_to_non_nullable
              as int?,
      height: freezed == height
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as int?,
      orientation: null == orientation
          ? _value.orientation
          : orientation // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WallpaperMetaImpl implements _WallpaperMeta {
  const _$WallpaperMetaImpl(
      {this.kind = 'static',
      this.width,
      this.height,
      this.orientation = 'portrait'});

  factory _$WallpaperMetaImpl.fromJson(Map<String, dynamic> json) =>
      _$$WallpaperMetaImplFromJson(json);

  @override
  @JsonKey()
  final String kind;
  @override
  final int? width;
  @override
  final int? height;
  @override
  @JsonKey()
  final String orientation;

  @override
  String toString() {
    return 'WallpaperMeta(kind: $kind, width: $width, height: $height, orientation: $orientation)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WallpaperMetaImpl &&
            (identical(other.kind, kind) || other.kind == kind) &&
            (identical(other.width, width) || other.width == width) &&
            (identical(other.height, height) || other.height == height) &&
            (identical(other.orientation, orientation) ||
                other.orientation == orientation));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, kind, width, height, orientation);

  /// Create a copy of WallpaperMeta
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WallpaperMetaImplCopyWith<_$WallpaperMetaImpl> get copyWith =>
      __$$WallpaperMetaImplCopyWithImpl<_$WallpaperMetaImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WallpaperMetaImplToJson(
      this,
    );
  }
}

abstract class _WallpaperMeta implements WallpaperMeta {
  const factory _WallpaperMeta(
      {final String kind,
      final int? width,
      final int? height,
      final String orientation}) = _$WallpaperMetaImpl;

  factory _WallpaperMeta.fromJson(Map<String, dynamic> json) =
      _$WallpaperMetaImpl.fromJson;

  @override
  String get kind;
  @override
  int? get width;
  @override
  int? get height;
  @override
  String get orientation;

  /// Create a copy of WallpaperMeta
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WallpaperMetaImplCopyWith<_$WallpaperMetaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AudioMeta _$AudioMetaFromJson(Map<String, dynamic> json) {
  return _AudioMeta.fromJson(json);
}

/// @nodoc
mixin _$AudioMeta {
  int? get durationSec => throw _privateConstructorUsedError;
  String? get waveformUrl => throw _privateConstructorUsedError;

  /// Groups multi-part meditation series (e.g. "AnaPana Meditation").
  String? get seriesId => throw _privateConstructorUsedError;
  int? get partNumber => throw _privateConstructorUsedError;

  /// `beginner` | `intermediate` — meditation only.
  String? get level => throw _privateConstructorUsedError;

  /// Serializes this AudioMeta to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AudioMeta
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AudioMetaCopyWith<AudioMeta> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AudioMetaCopyWith<$Res> {
  factory $AudioMetaCopyWith(AudioMeta value, $Res Function(AudioMeta) then) =
      _$AudioMetaCopyWithImpl<$Res, AudioMeta>;
  @useResult
  $Res call(
      {int? durationSec,
      String? waveformUrl,
      String? seriesId,
      int? partNumber,
      String? level});
}

/// @nodoc
class _$AudioMetaCopyWithImpl<$Res, $Val extends AudioMeta>
    implements $AudioMetaCopyWith<$Res> {
  _$AudioMetaCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AudioMeta
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? durationSec = freezed,
    Object? waveformUrl = freezed,
    Object? seriesId = freezed,
    Object? partNumber = freezed,
    Object? level = freezed,
  }) {
    return _then(_value.copyWith(
      durationSec: freezed == durationSec
          ? _value.durationSec
          : durationSec // ignore: cast_nullable_to_non_nullable
              as int?,
      waveformUrl: freezed == waveformUrl
          ? _value.waveformUrl
          : waveformUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      seriesId: freezed == seriesId
          ? _value.seriesId
          : seriesId // ignore: cast_nullable_to_non_nullable
              as String?,
      partNumber: freezed == partNumber
          ? _value.partNumber
          : partNumber // ignore: cast_nullable_to_non_nullable
              as int?,
      level: freezed == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AudioMetaImplCopyWith<$Res>
    implements $AudioMetaCopyWith<$Res> {
  factory _$$AudioMetaImplCopyWith(
          _$AudioMetaImpl value, $Res Function(_$AudioMetaImpl) then) =
      __$$AudioMetaImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? durationSec,
      String? waveformUrl,
      String? seriesId,
      int? partNumber,
      String? level});
}

/// @nodoc
class __$$AudioMetaImplCopyWithImpl<$Res>
    extends _$AudioMetaCopyWithImpl<$Res, _$AudioMetaImpl>
    implements _$$AudioMetaImplCopyWith<$Res> {
  __$$AudioMetaImplCopyWithImpl(
      _$AudioMetaImpl _value, $Res Function(_$AudioMetaImpl) _then)
      : super(_value, _then);

  /// Create a copy of AudioMeta
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? durationSec = freezed,
    Object? waveformUrl = freezed,
    Object? seriesId = freezed,
    Object? partNumber = freezed,
    Object? level = freezed,
  }) {
    return _then(_$AudioMetaImpl(
      durationSec: freezed == durationSec
          ? _value.durationSec
          : durationSec // ignore: cast_nullable_to_non_nullable
              as int?,
      waveformUrl: freezed == waveformUrl
          ? _value.waveformUrl
          : waveformUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      seriesId: freezed == seriesId
          ? _value.seriesId
          : seriesId // ignore: cast_nullable_to_non_nullable
              as String?,
      partNumber: freezed == partNumber
          ? _value.partNumber
          : partNumber // ignore: cast_nullable_to_non_nullable
              as int?,
      level: freezed == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AudioMetaImpl implements _AudioMeta {
  const _$AudioMetaImpl(
      {this.durationSec,
      this.waveformUrl,
      this.seriesId,
      this.partNumber,
      this.level});

  factory _$AudioMetaImpl.fromJson(Map<String, dynamic> json) =>
      _$$AudioMetaImplFromJson(json);

  @override
  final int? durationSec;
  @override
  final String? waveformUrl;

  /// Groups multi-part meditation series (e.g. "AnaPana Meditation").
  @override
  final String? seriesId;
  @override
  final int? partNumber;

  /// `beginner` | `intermediate` — meditation only.
  @override
  final String? level;

  @override
  String toString() {
    return 'AudioMeta(durationSec: $durationSec, waveformUrl: $waveformUrl, seriesId: $seriesId, partNumber: $partNumber, level: $level)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AudioMetaImpl &&
            (identical(other.durationSec, durationSec) ||
                other.durationSec == durationSec) &&
            (identical(other.waveformUrl, waveformUrl) ||
                other.waveformUrl == waveformUrl) &&
            (identical(other.seriesId, seriesId) ||
                other.seriesId == seriesId) &&
            (identical(other.partNumber, partNumber) ||
                other.partNumber == partNumber) &&
            (identical(other.level, level) || other.level == level));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, durationSec, waveformUrl, seriesId, partNumber, level);

  /// Create a copy of AudioMeta
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AudioMetaImplCopyWith<_$AudioMetaImpl> get copyWith =>
      __$$AudioMetaImplCopyWithImpl<_$AudioMetaImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AudioMetaImplToJson(
      this,
    );
  }
}

abstract class _AudioMeta implements AudioMeta {
  const factory _AudioMeta(
      {final int? durationSec,
      final String? waveformUrl,
      final String? seriesId,
      final int? partNumber,
      final String? level}) = _$AudioMetaImpl;

  factory _AudioMeta.fromJson(Map<String, dynamic> json) =
      _$AudioMetaImpl.fromJson;

  @override
  int? get durationSec;
  @override
  String? get waveformUrl;

  /// Groups multi-part meditation series (e.g. "AnaPana Meditation").
  @override
  String? get seriesId;
  @override
  int? get partNumber;

  /// `beginner` | `intermediate` — meditation only.
  @override
  String? get level;

  /// Create a copy of AudioMeta
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AudioMetaImplCopyWith<_$AudioMetaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LayoutRect _$LayoutRectFromJson(Map<String, dynamic> json) {
  return _LayoutRect.fromJson(json);
}

/// @nodoc
mixin _$LayoutRect {
  double get x => throw _privateConstructorUsedError;
  double get y => throw _privateConstructorUsedError;
  double get w => throw _privateConstructorUsedError;
  double get h => throw _privateConstructorUsedError;

  /// Serializes this LayoutRect to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LayoutRect
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LayoutRectCopyWith<LayoutRect> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LayoutRectCopyWith<$Res> {
  factory $LayoutRectCopyWith(
          LayoutRect value, $Res Function(LayoutRect) then) =
      _$LayoutRectCopyWithImpl<$Res, LayoutRect>;
  @useResult
  $Res call({double x, double y, double w, double h});
}

/// @nodoc
class _$LayoutRectCopyWithImpl<$Res, $Val extends LayoutRect>
    implements $LayoutRectCopyWith<$Res> {
  _$LayoutRectCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LayoutRect
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? x = null,
    Object? y = null,
    Object? w = null,
    Object? h = null,
  }) {
    return _then(_value.copyWith(
      x: null == x
          ? _value.x
          : x // ignore: cast_nullable_to_non_nullable
              as double,
      y: null == y
          ? _value.y
          : y // ignore: cast_nullable_to_non_nullable
              as double,
      w: null == w
          ? _value.w
          : w // ignore: cast_nullable_to_non_nullable
              as double,
      h: null == h
          ? _value.h
          : h // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LayoutRectImplCopyWith<$Res>
    implements $LayoutRectCopyWith<$Res> {
  factory _$$LayoutRectImplCopyWith(
          _$LayoutRectImpl value, $Res Function(_$LayoutRectImpl) then) =
      __$$LayoutRectImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double x, double y, double w, double h});
}

/// @nodoc
class __$$LayoutRectImplCopyWithImpl<$Res>
    extends _$LayoutRectCopyWithImpl<$Res, _$LayoutRectImpl>
    implements _$$LayoutRectImplCopyWith<$Res> {
  __$$LayoutRectImplCopyWithImpl(
      _$LayoutRectImpl _value, $Res Function(_$LayoutRectImpl) _then)
      : super(_value, _then);

  /// Create a copy of LayoutRect
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? x = null,
    Object? y = null,
    Object? w = null,
    Object? h = null,
  }) {
    return _then(_$LayoutRectImpl(
      x: null == x
          ? _value.x
          : x // ignore: cast_nullable_to_non_nullable
              as double,
      y: null == y
          ? _value.y
          : y // ignore: cast_nullable_to_non_nullable
              as double,
      w: null == w
          ? _value.w
          : w // ignore: cast_nullable_to_non_nullable
              as double,
      h: null == h
          ? _value.h
          : h // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LayoutRectImpl implements _LayoutRect {
  const _$LayoutRectImpl({this.x = 0, this.y = 0, this.w = 0, this.h = 0});

  factory _$LayoutRectImpl.fromJson(Map<String, dynamic> json) =>
      _$$LayoutRectImplFromJson(json);

  @override
  @JsonKey()
  final double x;
  @override
  @JsonKey()
  final double y;
  @override
  @JsonKey()
  final double w;
  @override
  @JsonKey()
  final double h;

  @override
  String toString() {
    return 'LayoutRect(x: $x, y: $y, w: $w, h: $h)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LayoutRectImpl &&
            (identical(other.x, x) || other.x == x) &&
            (identical(other.y, y) || other.y == y) &&
            (identical(other.w, w) || other.w == w) &&
            (identical(other.h, h) || other.h == h));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, x, y, w, h);

  /// Create a copy of LayoutRect
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LayoutRectImplCopyWith<_$LayoutRectImpl> get copyWith =>
      __$$LayoutRectImplCopyWithImpl<_$LayoutRectImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LayoutRectImplToJson(
      this,
    );
  }
}

abstract class _LayoutRect implements LayoutRect {
  const factory _LayoutRect(
      {final double x,
      final double y,
      final double w,
      final double h}) = _$LayoutRectImpl;

  factory _LayoutRect.fromJson(Map<String, dynamic> json) =
      _$LayoutRectImpl.fromJson;

  @override
  double get x;
  @override
  double get y;
  @override
  double get w;
  @override
  double get h;

  /// Create a copy of LayoutRect
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LayoutRectImplCopyWith<_$LayoutRectImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StatusTextStyle _$StatusTextStyleFromJson(Map<String, dynamic> json) {
  return _StatusTextStyle.fromJson(json);
}

/// @nodoc
mixin _$StatusTextStyle {
  double get x => throw _privateConstructorUsedError;
  double get y => throw _privateConstructorUsedError;
  double get w => throw _privateConstructorUsedError;
  String get align => throw _privateConstructorUsedError;
  String get font => throw _privateConstructorUsedError;

  /// Font size as a fraction of the rendered image height.
  double get size => throw _privateConstructorUsedError;
  String get color => throw _privateConstructorUsedError;
  int get weight => throw _privateConstructorUsedError;

  /// Serializes this StatusTextStyle to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StatusTextStyle
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StatusTextStyleCopyWith<StatusTextStyle> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StatusTextStyleCopyWith<$Res> {
  factory $StatusTextStyleCopyWith(
          StatusTextStyle value, $Res Function(StatusTextStyle) then) =
      _$StatusTextStyleCopyWithImpl<$Res, StatusTextStyle>;
  @useResult
  $Res call(
      {double x,
      double y,
      double w,
      String align,
      String font,
      double size,
      String color,
      int weight});
}

/// @nodoc
class _$StatusTextStyleCopyWithImpl<$Res, $Val extends StatusTextStyle>
    implements $StatusTextStyleCopyWith<$Res> {
  _$StatusTextStyleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StatusTextStyle
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? x = null,
    Object? y = null,
    Object? w = null,
    Object? align = null,
    Object? font = null,
    Object? size = null,
    Object? color = null,
    Object? weight = null,
  }) {
    return _then(_value.copyWith(
      x: null == x
          ? _value.x
          : x // ignore: cast_nullable_to_non_nullable
              as double,
      y: null == y
          ? _value.y
          : y // ignore: cast_nullable_to_non_nullable
              as double,
      w: null == w
          ? _value.w
          : w // ignore: cast_nullable_to_non_nullable
              as double,
      align: null == align
          ? _value.align
          : align // ignore: cast_nullable_to_non_nullable
              as String,
      font: null == font
          ? _value.font
          : font // ignore: cast_nullable_to_non_nullable
              as String,
      size: null == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as double,
      color: null == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String,
      weight: null == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StatusTextStyleImplCopyWith<$Res>
    implements $StatusTextStyleCopyWith<$Res> {
  factory _$$StatusTextStyleImplCopyWith(_$StatusTextStyleImpl value,
          $Res Function(_$StatusTextStyleImpl) then) =
      __$$StatusTextStyleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double x,
      double y,
      double w,
      String align,
      String font,
      double size,
      String color,
      int weight});
}

/// @nodoc
class __$$StatusTextStyleImplCopyWithImpl<$Res>
    extends _$StatusTextStyleCopyWithImpl<$Res, _$StatusTextStyleImpl>
    implements _$$StatusTextStyleImplCopyWith<$Res> {
  __$$StatusTextStyleImplCopyWithImpl(
      _$StatusTextStyleImpl _value, $Res Function(_$StatusTextStyleImpl) _then)
      : super(_value, _then);

  /// Create a copy of StatusTextStyle
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? x = null,
    Object? y = null,
    Object? w = null,
    Object? align = null,
    Object? font = null,
    Object? size = null,
    Object? color = null,
    Object? weight = null,
  }) {
    return _then(_$StatusTextStyleImpl(
      x: null == x
          ? _value.x
          : x // ignore: cast_nullable_to_non_nullable
              as double,
      y: null == y
          ? _value.y
          : y // ignore: cast_nullable_to_non_nullable
              as double,
      w: null == w
          ? _value.w
          : w // ignore: cast_nullable_to_non_nullable
              as double,
      align: null == align
          ? _value.align
          : align // ignore: cast_nullable_to_non_nullable
              as String,
      font: null == font
          ? _value.font
          : font // ignore: cast_nullable_to_non_nullable
              as String,
      size: null == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as double,
      color: null == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String,
      weight: null == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StatusTextStyleImpl implements _StatusTextStyle {
  const _$StatusTextStyleImpl(
      {this.x = 0,
      this.y = 0,
      this.w = 0.6,
      this.align = 'left',
      this.font = 'Poppins',
      this.size = 0.045,
      this.color = '#1F1F1F',
      this.weight = 700});

  factory _$StatusTextStyleImpl.fromJson(Map<String, dynamic> json) =>
      _$$StatusTextStyleImplFromJson(json);

  @override
  @JsonKey()
  final double x;
  @override
  @JsonKey()
  final double y;
  @override
  @JsonKey()
  final double w;
  @override
  @JsonKey()
  final String align;
  @override
  @JsonKey()
  final String font;

  /// Font size as a fraction of the rendered image height.
  @override
  @JsonKey()
  final double size;
  @override
  @JsonKey()
  final String color;
  @override
  @JsonKey()
  final int weight;

  @override
  String toString() {
    return 'StatusTextStyle(x: $x, y: $y, w: $w, align: $align, font: $font, size: $size, color: $color, weight: $weight)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StatusTextStyleImpl &&
            (identical(other.x, x) || other.x == x) &&
            (identical(other.y, y) || other.y == y) &&
            (identical(other.w, w) || other.w == w) &&
            (identical(other.align, align) || other.align == align) &&
            (identical(other.font, font) || other.font == font) &&
            (identical(other.size, size) || other.size == size) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.weight, weight) || other.weight == weight));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, x, y, w, align, font, size, color, weight);

  /// Create a copy of StatusTextStyle
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StatusTextStyleImplCopyWith<_$StatusTextStyleImpl> get copyWith =>
      __$$StatusTextStyleImplCopyWithImpl<_$StatusTextStyleImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StatusTextStyleImplToJson(
      this,
    );
  }
}

abstract class _StatusTextStyle implements StatusTextStyle {
  const factory _StatusTextStyle(
      {final double x,
      final double y,
      final double w,
      final String align,
      final String font,
      final double size,
      final String color,
      final int weight}) = _$StatusTextStyleImpl;

  factory _StatusTextStyle.fromJson(Map<String, dynamic> json) =
      _$StatusTextStyleImpl.fromJson;

  @override
  double get x;
  @override
  double get y;
  @override
  double get w;
  @override
  String get align;
  @override
  String get font;

  /// Font size as a fraction of the rendered image height.
  @override
  double get size;
  @override
  String get color;
  @override
  int get weight;

  /// Create a copy of StatusTextStyle
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StatusTextStyleImplCopyWith<_$StatusTextStyleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StatusMeta _$StatusMetaFromJson(Map<String, dynamic> json) {
  return _StatusMeta.fromJson(json);
}

/// @nodoc
mixin _$StatusMeta {
  LayoutRect get photoFrame => throw _privateConstructorUsedError;
  StatusTextStyle get nameText => throw _privateConstructorUsedError;
  bool get watermark => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get festivalDate => throw _privateConstructorUsedError;

  /// Serializes this StatusMeta to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StatusMeta
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StatusMetaCopyWith<StatusMeta> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StatusMetaCopyWith<$Res> {
  factory $StatusMetaCopyWith(
          StatusMeta value, $Res Function(StatusMeta) then) =
      _$StatusMetaCopyWithImpl<$Res, StatusMeta>;
  @useResult
  $Res call(
      {LayoutRect photoFrame,
      StatusTextStyle nameText,
      bool watermark,
      @TimestampConverter() DateTime? festivalDate});

  $LayoutRectCopyWith<$Res> get photoFrame;
  $StatusTextStyleCopyWith<$Res> get nameText;
}

/// @nodoc
class _$StatusMetaCopyWithImpl<$Res, $Val extends StatusMeta>
    implements $StatusMetaCopyWith<$Res> {
  _$StatusMetaCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StatusMeta
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? photoFrame = null,
    Object? nameText = null,
    Object? watermark = null,
    Object? festivalDate = freezed,
  }) {
    return _then(_value.copyWith(
      photoFrame: null == photoFrame
          ? _value.photoFrame
          : photoFrame // ignore: cast_nullable_to_non_nullable
              as LayoutRect,
      nameText: null == nameText
          ? _value.nameText
          : nameText // ignore: cast_nullable_to_non_nullable
              as StatusTextStyle,
      watermark: null == watermark
          ? _value.watermark
          : watermark // ignore: cast_nullable_to_non_nullable
              as bool,
      festivalDate: freezed == festivalDate
          ? _value.festivalDate
          : festivalDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }

  /// Create a copy of StatusMeta
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LayoutRectCopyWith<$Res> get photoFrame {
    return $LayoutRectCopyWith<$Res>(_value.photoFrame, (value) {
      return _then(_value.copyWith(photoFrame: value) as $Val);
    });
  }

  /// Create a copy of StatusMeta
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $StatusTextStyleCopyWith<$Res> get nameText {
    return $StatusTextStyleCopyWith<$Res>(_value.nameText, (value) {
      return _then(_value.copyWith(nameText: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$StatusMetaImplCopyWith<$Res>
    implements $StatusMetaCopyWith<$Res> {
  factory _$$StatusMetaImplCopyWith(
          _$StatusMetaImpl value, $Res Function(_$StatusMetaImpl) then) =
      __$$StatusMetaImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {LayoutRect photoFrame,
      StatusTextStyle nameText,
      bool watermark,
      @TimestampConverter() DateTime? festivalDate});

  @override
  $LayoutRectCopyWith<$Res> get photoFrame;
  @override
  $StatusTextStyleCopyWith<$Res> get nameText;
}

/// @nodoc
class __$$StatusMetaImplCopyWithImpl<$Res>
    extends _$StatusMetaCopyWithImpl<$Res, _$StatusMetaImpl>
    implements _$$StatusMetaImplCopyWith<$Res> {
  __$$StatusMetaImplCopyWithImpl(
      _$StatusMetaImpl _value, $Res Function(_$StatusMetaImpl) _then)
      : super(_value, _then);

  /// Create a copy of StatusMeta
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? photoFrame = null,
    Object? nameText = null,
    Object? watermark = null,
    Object? festivalDate = freezed,
  }) {
    return _then(_$StatusMetaImpl(
      photoFrame: null == photoFrame
          ? _value.photoFrame
          : photoFrame // ignore: cast_nullable_to_non_nullable
              as LayoutRect,
      nameText: null == nameText
          ? _value.nameText
          : nameText // ignore: cast_nullable_to_non_nullable
              as StatusTextStyle,
      watermark: null == watermark
          ? _value.watermark
          : watermark // ignore: cast_nullable_to_non_nullable
              as bool,
      festivalDate: freezed == festivalDate
          ? _value.festivalDate
          : festivalDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StatusMetaImpl implements _StatusMeta {
  const _$StatusMetaImpl(
      {this.photoFrame = const LayoutRect(x: 0.62, y: 0.70, w: 0.22, h: 0.22),
      this.nameText = const StatusTextStyle(),
      this.watermark = true,
      @TimestampConverter() this.festivalDate});

  factory _$StatusMetaImpl.fromJson(Map<String, dynamic> json) =>
      _$$StatusMetaImplFromJson(json);

  @override
  @JsonKey()
  final LayoutRect photoFrame;
  @override
  @JsonKey()
  final StatusTextStyle nameText;
  @override
  @JsonKey()
  final bool watermark;
  @override
  @TimestampConverter()
  final DateTime? festivalDate;

  @override
  String toString() {
    return 'StatusMeta(photoFrame: $photoFrame, nameText: $nameText, watermark: $watermark, festivalDate: $festivalDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StatusMetaImpl &&
            (identical(other.photoFrame, photoFrame) ||
                other.photoFrame == photoFrame) &&
            (identical(other.nameText, nameText) ||
                other.nameText == nameText) &&
            (identical(other.watermark, watermark) ||
                other.watermark == watermark) &&
            (identical(other.festivalDate, festivalDate) ||
                other.festivalDate == festivalDate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, photoFrame, nameText, watermark, festivalDate);

  /// Create a copy of StatusMeta
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StatusMetaImplCopyWith<_$StatusMetaImpl> get copyWith =>
      __$$StatusMetaImplCopyWithImpl<_$StatusMetaImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StatusMetaImplToJson(
      this,
    );
  }
}

abstract class _StatusMeta implements StatusMeta {
  const factory _StatusMeta(
      {final LayoutRect photoFrame,
      final StatusTextStyle nameText,
      final bool watermark,
      @TimestampConverter() final DateTime? festivalDate}) = _$StatusMetaImpl;

  factory _StatusMeta.fromJson(Map<String, dynamic> json) =
      _$StatusMetaImpl.fromJson;

  @override
  LayoutRect get photoFrame;
  @override
  StatusTextStyle get nameText;
  @override
  bool get watermark;
  @override
  @TimestampConverter()
  DateTime? get festivalDate;

  /// Create a copy of StatusMeta
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StatusMetaImplCopyWith<_$StatusMetaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
