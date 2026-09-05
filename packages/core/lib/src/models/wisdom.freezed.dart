// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wisdom.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Wisdom _$WisdomFromJson(Map<String, dynamic> json) {
  return _Wisdom.fromJson(json);
}

/// @nodoc
mixin _$Wisdom {
  String get id => throw _privateConstructorUsedError;
  LocalisedText get title => throw _privateConstructorUsedError;
  LocalisedText get body => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  int get sortOrder => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this Wisdom to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Wisdom
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WisdomCopyWith<Wisdom> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WisdomCopyWith<$Res> {
  factory $WisdomCopyWith(Wisdom value, $Res Function(Wisdom) then) =
      _$WisdomCopyWithImpl<$Res, Wisdom>;
  @useResult
  $Res call(
      {String id,
      LocalisedText title,
      LocalisedText body,
      String? imageUrl,
      int sortOrder,
      bool isActive});

  $LocalisedTextCopyWith<$Res> get title;
  $LocalisedTextCopyWith<$Res> get body;
}

/// @nodoc
class _$WisdomCopyWithImpl<$Res, $Val extends Wisdom>
    implements $WisdomCopyWith<$Res> {
  _$WisdomCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Wisdom
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? body = null,
    Object? imageUrl = freezed,
    Object? sortOrder = null,
    Object? isActive = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as LocalisedText,
      body: null == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as LocalisedText,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  /// Create a copy of Wisdom
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LocalisedTextCopyWith<$Res> get title {
    return $LocalisedTextCopyWith<$Res>(_value.title, (value) {
      return _then(_value.copyWith(title: value) as $Val);
    });
  }

  /// Create a copy of Wisdom
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LocalisedTextCopyWith<$Res> get body {
    return $LocalisedTextCopyWith<$Res>(_value.body, (value) {
      return _then(_value.copyWith(body: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$WisdomImplCopyWith<$Res> implements $WisdomCopyWith<$Res> {
  factory _$$WisdomImplCopyWith(
          _$WisdomImpl value, $Res Function(_$WisdomImpl) then) =
      __$$WisdomImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      LocalisedText title,
      LocalisedText body,
      String? imageUrl,
      int sortOrder,
      bool isActive});

  @override
  $LocalisedTextCopyWith<$Res> get title;
  @override
  $LocalisedTextCopyWith<$Res> get body;
}

/// @nodoc
class __$$WisdomImplCopyWithImpl<$Res>
    extends _$WisdomCopyWithImpl<$Res, _$WisdomImpl>
    implements _$$WisdomImplCopyWith<$Res> {
  __$$WisdomImplCopyWithImpl(
      _$WisdomImpl _value, $Res Function(_$WisdomImpl) _then)
      : super(_value, _then);

  /// Create a copy of Wisdom
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? body = null,
    Object? imageUrl = freezed,
    Object? sortOrder = null,
    Object? isActive = null,
  }) {
    return _then(_$WisdomImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as LocalisedText,
      body: null == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as LocalisedText,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WisdomImpl implements _Wisdom {
  const _$WisdomImpl(
      {required this.id,
      required this.title,
      required this.body,
      this.imageUrl,
      this.sortOrder = 0,
      this.isActive = true});

  factory _$WisdomImpl.fromJson(Map<String, dynamic> json) =>
      _$$WisdomImplFromJson(json);

  @override
  final String id;
  @override
  final LocalisedText title;
  @override
  final LocalisedText body;
  @override
  final String? imageUrl;
  @override
  @JsonKey()
  final int sortOrder;
  @override
  @JsonKey()
  final bool isActive;

  @override
  String toString() {
    return 'Wisdom(id: $id, title: $title, body: $body, imageUrl: $imageUrl, sortOrder: $sortOrder, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WisdomImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, title, body, imageUrl, sortOrder, isActive);

  /// Create a copy of Wisdom
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WisdomImplCopyWith<_$WisdomImpl> get copyWith =>
      __$$WisdomImplCopyWithImpl<_$WisdomImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WisdomImplToJson(
      this,
    );
  }
}

abstract class _Wisdom implements Wisdom {
  const factory _Wisdom(
      {required final String id,
      required final LocalisedText title,
      required final LocalisedText body,
      final String? imageUrl,
      final int sortOrder,
      final bool isActive}) = _$WisdomImpl;

  factory _Wisdom.fromJson(Map<String, dynamic> json) = _$WisdomImpl.fromJson;

  @override
  String get id;
  @override
  LocalisedText get title;
  @override
  LocalisedText get body;
  @override
  String? get imageUrl;
  @override
  int get sortOrder;
  @override
  bool get isActive;

  /// Create a copy of Wisdom
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WisdomImplCopyWith<_$WisdomImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
