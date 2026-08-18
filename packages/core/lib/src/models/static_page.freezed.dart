// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'static_page.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

StaticPage _$StaticPageFromJson(Map<String, dynamic> json) {
  return _StaticPage.fromJson(json);
}

/// @nodoc
mixin _$StaticPage {
  String get slug => throw _privateConstructorUsedError;
  LocalisedText get title => throw _privateConstructorUsedError;

  /// Rich text (HTML or Markdown — decided at implementation time in
  /// the editor task) per language.
  LocalisedText get body => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this StaticPage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StaticPage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StaticPageCopyWith<StaticPage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StaticPageCopyWith<$Res> {
  factory $StaticPageCopyWith(
          StaticPage value, $Res Function(StaticPage) then) =
      _$StaticPageCopyWithImpl<$Res, StaticPage>;
  @useResult
  $Res call(
      {String slug,
      LocalisedText title,
      LocalisedText body,
      @TimestampConverter() DateTime? updatedAt});

  $LocalisedTextCopyWith<$Res> get title;
  $LocalisedTextCopyWith<$Res> get body;
}

/// @nodoc
class _$StaticPageCopyWithImpl<$Res, $Val extends StaticPage>
    implements $StaticPageCopyWith<$Res> {
  _$StaticPageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StaticPage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? slug = null,
    Object? title = null,
    Object? body = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      slug: null == slug
          ? _value.slug
          : slug // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as LocalisedText,
      body: null == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as LocalisedText,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }

  /// Create a copy of StaticPage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LocalisedTextCopyWith<$Res> get title {
    return $LocalisedTextCopyWith<$Res>(_value.title, (value) {
      return _then(_value.copyWith(title: value) as $Val);
    });
  }

  /// Create a copy of StaticPage
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
abstract class _$$StaticPageImplCopyWith<$Res>
    implements $StaticPageCopyWith<$Res> {
  factory _$$StaticPageImplCopyWith(
          _$StaticPageImpl value, $Res Function(_$StaticPageImpl) then) =
      __$$StaticPageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String slug,
      LocalisedText title,
      LocalisedText body,
      @TimestampConverter() DateTime? updatedAt});

  @override
  $LocalisedTextCopyWith<$Res> get title;
  @override
  $LocalisedTextCopyWith<$Res> get body;
}

/// @nodoc
class __$$StaticPageImplCopyWithImpl<$Res>
    extends _$StaticPageCopyWithImpl<$Res, _$StaticPageImpl>
    implements _$$StaticPageImplCopyWith<$Res> {
  __$$StaticPageImplCopyWithImpl(
      _$StaticPageImpl _value, $Res Function(_$StaticPageImpl) _then)
      : super(_value, _then);

  /// Create a copy of StaticPage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? slug = null,
    Object? title = null,
    Object? body = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_$StaticPageImpl(
      slug: null == slug
          ? _value.slug
          : slug // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as LocalisedText,
      body: null == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as LocalisedText,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StaticPageImpl implements _StaticPage {
  const _$StaticPageImpl(
      {required this.slug,
      required this.title,
      required this.body,
      @TimestampConverter() this.updatedAt});

  factory _$StaticPageImpl.fromJson(Map<String, dynamic> json) =>
      _$$StaticPageImplFromJson(json);

  @override
  final String slug;
  @override
  final LocalisedText title;

  /// Rich text (HTML or Markdown — decided at implementation time in
  /// the editor task) per language.
  @override
  final LocalisedText body;
  @override
  @TimestampConverter()
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'StaticPage(slug: $slug, title: $title, body: $body, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StaticPageImpl &&
            (identical(other.slug, slug) || other.slug == slug) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, slug, title, body, updatedAt);

  /// Create a copy of StaticPage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StaticPageImplCopyWith<_$StaticPageImpl> get copyWith =>
      __$$StaticPageImplCopyWithImpl<_$StaticPageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StaticPageImplToJson(
      this,
    );
  }
}

abstract class _StaticPage implements StaticPage {
  const factory _StaticPage(
      {required final String slug,
      required final LocalisedText title,
      required final LocalisedText body,
      @TimestampConverter() final DateTime? updatedAt}) = _$StaticPageImpl;

  factory _StaticPage.fromJson(Map<String, dynamic> json) =
      _$StaticPageImpl.fromJson;

  @override
  String get slug;
  @override
  LocalisedText get title;

  /// Rich text (HTML or Markdown — decided at implementation time in
  /// the editor task) per language.
  @override
  LocalisedText get body;
  @override
  @TimestampConverter()
  DateTime? get updatedAt;

  /// Create a copy of StaticPage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StaticPageImplCopyWith<_$StaticPageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
