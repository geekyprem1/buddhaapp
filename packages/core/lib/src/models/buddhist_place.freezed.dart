// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'buddhist_place.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

BuddhistPlace _$BuddhistPlaceFromJson(Map<String, dynamic> json) {
  return _BuddhistPlace.fromJson(json);
}

/// @nodoc
mixin _$BuddhistPlace {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String? get thumbUrl => throw _privateConstructorUsedError;
  List<String> get imageUrls => throw _privateConstructorUsedError;
  int get sortOrder => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this BuddhistPlace to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BuddhistPlace
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BuddhistPlaceCopyWith<BuddhistPlace> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BuddhistPlaceCopyWith<$Res> {
  factory $BuddhistPlaceCopyWith(
          BuddhistPlace value, $Res Function(BuddhistPlace) then) =
      _$BuddhistPlaceCopyWithImpl<$Res, BuddhistPlace>;
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      String? thumbUrl,
      List<String> imageUrls,
      int sortOrder,
      bool isActive});
}

/// @nodoc
class _$BuddhistPlaceCopyWithImpl<$Res, $Val extends BuddhistPlace>
    implements $BuddhistPlaceCopyWith<$Res> {
  _$BuddhistPlaceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BuddhistPlace
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? thumbUrl = freezed,
    Object? imageUrls = null,
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
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      thumbUrl: freezed == thumbUrl
          ? _value.thumbUrl
          : thumbUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrls: null == imageUrls
          ? _value.imageUrls
          : imageUrls // ignore: cast_nullable_to_non_nullable
              as List<String>,
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
}

/// @nodoc
abstract class _$$BuddhistPlaceImplCopyWith<$Res>
    implements $BuddhistPlaceCopyWith<$Res> {
  factory _$$BuddhistPlaceImplCopyWith(
          _$BuddhistPlaceImpl value, $Res Function(_$BuddhistPlaceImpl) then) =
      __$$BuddhistPlaceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      String? thumbUrl,
      List<String> imageUrls,
      int sortOrder,
      bool isActive});
}

/// @nodoc
class __$$BuddhistPlaceImplCopyWithImpl<$Res>
    extends _$BuddhistPlaceCopyWithImpl<$Res, _$BuddhistPlaceImpl>
    implements _$$BuddhistPlaceImplCopyWith<$Res> {
  __$$BuddhistPlaceImplCopyWithImpl(
      _$BuddhistPlaceImpl _value, $Res Function(_$BuddhistPlaceImpl) _then)
      : super(_value, _then);

  /// Create a copy of BuddhistPlace
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? thumbUrl = freezed,
    Object? imageUrls = null,
    Object? sortOrder = null,
    Object? isActive = null,
  }) {
    return _then(_$BuddhistPlaceImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      thumbUrl: freezed == thumbUrl
          ? _value.thumbUrl
          : thumbUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrls: null == imageUrls
          ? _value._imageUrls
          : imageUrls // ignore: cast_nullable_to_non_nullable
              as List<String>,
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
class _$BuddhistPlaceImpl implements _BuddhistPlace {
  const _$BuddhistPlaceImpl(
      {required this.id,
      required this.title,
      this.description = '',
      this.thumbUrl,
      final List<String> imageUrls = const <String>[],
      this.sortOrder = 0,
      this.isActive = true})
      : _imageUrls = imageUrls;

  factory _$BuddhistPlaceImpl.fromJson(Map<String, dynamic> json) =>
      _$$BuddhistPlaceImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  @JsonKey()
  final String description;
  @override
  final String? thumbUrl;
  final List<String> _imageUrls;
  @override
  @JsonKey()
  List<String> get imageUrls {
    if (_imageUrls is EqualUnmodifiableListView) return _imageUrls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_imageUrls);
  }

  @override
  @JsonKey()
  final int sortOrder;
  @override
  @JsonKey()
  final bool isActive;

  @override
  String toString() {
    return 'BuddhistPlace(id: $id, title: $title, description: $description, thumbUrl: $thumbUrl, imageUrls: $imageUrls, sortOrder: $sortOrder, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BuddhistPlaceImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.thumbUrl, thumbUrl) ||
                other.thumbUrl == thumbUrl) &&
            const DeepCollectionEquality()
                .equals(other._imageUrls, _imageUrls) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, title, description, thumbUrl,
      const DeepCollectionEquality().hash(_imageUrls), sortOrder, isActive);

  /// Create a copy of BuddhistPlace
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BuddhistPlaceImplCopyWith<_$BuddhistPlaceImpl> get copyWith =>
      __$$BuddhistPlaceImplCopyWithImpl<_$BuddhistPlaceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BuddhistPlaceImplToJson(
      this,
    );
  }
}

abstract class _BuddhistPlace implements BuddhistPlace {
  const factory _BuddhistPlace(
      {required final String id,
      required final String title,
      final String description,
      final String? thumbUrl,
      final List<String> imageUrls,
      final int sortOrder,
      final bool isActive}) = _$BuddhistPlaceImpl;

  factory _BuddhistPlace.fromJson(Map<String, dynamic> json) =
      _$BuddhistPlaceImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  String? get thumbUrl;
  @override
  List<String> get imageUrls;
  @override
  int get sortOrder;
  @override
  bool get isActive;

  /// Create a copy of BuddhistPlace
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BuddhistPlaceImplCopyWith<_$BuddhistPlaceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
