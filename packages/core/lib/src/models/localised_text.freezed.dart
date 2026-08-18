// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'localised_text.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LocalisedText _$LocalisedTextFromJson(Map<String, dynamic> json) {
  return _LocalisedText.fromJson(json);
}

/// @nodoc
mixin _$LocalisedText {
  String get en => throw _privateConstructorUsedError;
  String get hi => throw _privateConstructorUsedError;
  String get mr => throw _privateConstructorUsedError;

  /// Serializes this LocalisedText to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LocalisedText
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LocalisedTextCopyWith<LocalisedText> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LocalisedTextCopyWith<$Res> {
  factory $LocalisedTextCopyWith(
          LocalisedText value, $Res Function(LocalisedText) then) =
      _$LocalisedTextCopyWithImpl<$Res, LocalisedText>;
  @useResult
  $Res call({String en, String hi, String mr});
}

/// @nodoc
class _$LocalisedTextCopyWithImpl<$Res, $Val extends LocalisedText>
    implements $LocalisedTextCopyWith<$Res> {
  _$LocalisedTextCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LocalisedText
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? en = null,
    Object? hi = null,
    Object? mr = null,
  }) {
    return _then(_value.copyWith(
      en: null == en
          ? _value.en
          : en // ignore: cast_nullable_to_non_nullable
              as String,
      hi: null == hi
          ? _value.hi
          : hi // ignore: cast_nullable_to_non_nullable
              as String,
      mr: null == mr
          ? _value.mr
          : mr // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LocalisedTextImplCopyWith<$Res>
    implements $LocalisedTextCopyWith<$Res> {
  factory _$$LocalisedTextImplCopyWith(
          _$LocalisedTextImpl value, $Res Function(_$LocalisedTextImpl) then) =
      __$$LocalisedTextImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String en, String hi, String mr});
}

/// @nodoc
class __$$LocalisedTextImplCopyWithImpl<$Res>
    extends _$LocalisedTextCopyWithImpl<$Res, _$LocalisedTextImpl>
    implements _$$LocalisedTextImplCopyWith<$Res> {
  __$$LocalisedTextImplCopyWithImpl(
      _$LocalisedTextImpl _value, $Res Function(_$LocalisedTextImpl) _then)
      : super(_value, _then);

  /// Create a copy of LocalisedText
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? en = null,
    Object? hi = null,
    Object? mr = null,
  }) {
    return _then(_$LocalisedTextImpl(
      en: null == en
          ? _value.en
          : en // ignore: cast_nullable_to_non_nullable
              as String,
      hi: null == hi
          ? _value.hi
          : hi // ignore: cast_nullable_to_non_nullable
              as String,
      mr: null == mr
          ? _value.mr
          : mr // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LocalisedTextImpl implements _LocalisedText {
  const _$LocalisedTextImpl({this.en = '', this.hi = '', this.mr = ''});

  factory _$LocalisedTextImpl.fromJson(Map<String, dynamic> json) =>
      _$$LocalisedTextImplFromJson(json);

  @override
  @JsonKey()
  final String en;
  @override
  @JsonKey()
  final String hi;
  @override
  @JsonKey()
  final String mr;

  @override
  String toString() {
    return 'LocalisedText(en: $en, hi: $hi, mr: $mr)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LocalisedTextImpl &&
            (identical(other.en, en) || other.en == en) &&
            (identical(other.hi, hi) || other.hi == hi) &&
            (identical(other.mr, mr) || other.mr == mr));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, en, hi, mr);

  /// Create a copy of LocalisedText
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LocalisedTextImplCopyWith<_$LocalisedTextImpl> get copyWith =>
      __$$LocalisedTextImplCopyWithImpl<_$LocalisedTextImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LocalisedTextImplToJson(
      this,
    );
  }
}

abstract class _LocalisedText implements LocalisedText {
  const factory _LocalisedText(
      {final String en,
      final String hi,
      final String mr}) = _$LocalisedTextImpl;

  factory _LocalisedText.fromJson(Map<String, dynamic> json) =
      _$LocalisedTextImpl.fromJson;

  @override
  String get en;
  @override
  String get hi;
  @override
  String get mr;

  /// Create a copy of LocalisedText
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LocalisedTextImplCopyWith<_$LocalisedTextImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
