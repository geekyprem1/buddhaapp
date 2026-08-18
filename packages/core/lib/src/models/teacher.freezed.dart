// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'teacher.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Teacher _$TeacherFromJson(Map<String, dynamic> json) {
  return _Teacher.fromJson(json);
}

/// @nodoc
mixin _$Teacher {
  String get id => throw _privateConstructorUsedError;
  LocalisedText get name => throw _privateConstructorUsedError;
  String? get portraitUrl => throw _privateConstructorUsedError;
  String? get thumbUrl => throw _privateConstructorUsedError;
  LocalisedText? get bio => throw _privateConstructorUsedError;
  String? get signatureUrl => throw _privateConstructorUsedError;

  /// Prefix used for Supporter ID Card unique ids, e.g. `BUD`. Phase 2.
  String? get idCardPrefix => throw _privateConstructorUsedError;
  int get sortOrder => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this Teacher to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Teacher
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TeacherCopyWith<Teacher> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TeacherCopyWith<$Res> {
  factory $TeacherCopyWith(Teacher value, $Res Function(Teacher) then) =
      _$TeacherCopyWithImpl<$Res, Teacher>;
  @useResult
  $Res call(
      {String id,
      LocalisedText name,
      String? portraitUrl,
      String? thumbUrl,
      LocalisedText? bio,
      String? signatureUrl,
      String? idCardPrefix,
      int sortOrder,
      bool isActive});

  $LocalisedTextCopyWith<$Res> get name;
  $LocalisedTextCopyWith<$Res>? get bio;
}

/// @nodoc
class _$TeacherCopyWithImpl<$Res, $Val extends Teacher>
    implements $TeacherCopyWith<$Res> {
  _$TeacherCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Teacher
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? portraitUrl = freezed,
    Object? thumbUrl = freezed,
    Object? bio = freezed,
    Object? signatureUrl = freezed,
    Object? idCardPrefix = freezed,
    Object? sortOrder = null,
    Object? isActive = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as LocalisedText,
      portraitUrl: freezed == portraitUrl
          ? _value.portraitUrl
          : portraitUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      thumbUrl: freezed == thumbUrl
          ? _value.thumbUrl
          : thumbUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      bio: freezed == bio
          ? _value.bio
          : bio // ignore: cast_nullable_to_non_nullable
              as LocalisedText?,
      signatureUrl: freezed == signatureUrl
          ? _value.signatureUrl
          : signatureUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      idCardPrefix: freezed == idCardPrefix
          ? _value.idCardPrefix
          : idCardPrefix // ignore: cast_nullable_to_non_nullable
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

  /// Create a copy of Teacher
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LocalisedTextCopyWith<$Res> get name {
    return $LocalisedTextCopyWith<$Res>(_value.name, (value) {
      return _then(_value.copyWith(name: value) as $Val);
    });
  }

  /// Create a copy of Teacher
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LocalisedTextCopyWith<$Res>? get bio {
    if (_value.bio == null) {
      return null;
    }

    return $LocalisedTextCopyWith<$Res>(_value.bio!, (value) {
      return _then(_value.copyWith(bio: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TeacherImplCopyWith<$Res> implements $TeacherCopyWith<$Res> {
  factory _$$TeacherImplCopyWith(
          _$TeacherImpl value, $Res Function(_$TeacherImpl) then) =
      __$$TeacherImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      LocalisedText name,
      String? portraitUrl,
      String? thumbUrl,
      LocalisedText? bio,
      String? signatureUrl,
      String? idCardPrefix,
      int sortOrder,
      bool isActive});

  @override
  $LocalisedTextCopyWith<$Res> get name;
  @override
  $LocalisedTextCopyWith<$Res>? get bio;
}

/// @nodoc
class __$$TeacherImplCopyWithImpl<$Res>
    extends _$TeacherCopyWithImpl<$Res, _$TeacherImpl>
    implements _$$TeacherImplCopyWith<$Res> {
  __$$TeacherImplCopyWithImpl(
      _$TeacherImpl _value, $Res Function(_$TeacherImpl) _then)
      : super(_value, _then);

  /// Create a copy of Teacher
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? portraitUrl = freezed,
    Object? thumbUrl = freezed,
    Object? bio = freezed,
    Object? signatureUrl = freezed,
    Object? idCardPrefix = freezed,
    Object? sortOrder = null,
    Object? isActive = null,
  }) {
    return _then(_$TeacherImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as LocalisedText,
      portraitUrl: freezed == portraitUrl
          ? _value.portraitUrl
          : portraitUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      thumbUrl: freezed == thumbUrl
          ? _value.thumbUrl
          : thumbUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      bio: freezed == bio
          ? _value.bio
          : bio // ignore: cast_nullable_to_non_nullable
              as LocalisedText?,
      signatureUrl: freezed == signatureUrl
          ? _value.signatureUrl
          : signatureUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      idCardPrefix: freezed == idCardPrefix
          ? _value.idCardPrefix
          : idCardPrefix // ignore: cast_nullable_to_non_nullable
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
class _$TeacherImpl implements _Teacher {
  const _$TeacherImpl(
      {required this.id,
      required this.name,
      this.portraitUrl,
      this.thumbUrl,
      this.bio,
      this.signatureUrl,
      this.idCardPrefix,
      this.sortOrder = 0,
      this.isActive = true});

  factory _$TeacherImpl.fromJson(Map<String, dynamic> json) =>
      _$$TeacherImplFromJson(json);

  @override
  final String id;
  @override
  final LocalisedText name;
  @override
  final String? portraitUrl;
  @override
  final String? thumbUrl;
  @override
  final LocalisedText? bio;
  @override
  final String? signatureUrl;

  /// Prefix used for Supporter ID Card unique ids, e.g. `BUD`. Phase 2.
  @override
  final String? idCardPrefix;
  @override
  @JsonKey()
  final int sortOrder;
  @override
  @JsonKey()
  final bool isActive;

  @override
  String toString() {
    return 'Teacher(id: $id, name: $name, portraitUrl: $portraitUrl, thumbUrl: $thumbUrl, bio: $bio, signatureUrl: $signatureUrl, idCardPrefix: $idCardPrefix, sortOrder: $sortOrder, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TeacherImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.portraitUrl, portraitUrl) ||
                other.portraitUrl == portraitUrl) &&
            (identical(other.thumbUrl, thumbUrl) ||
                other.thumbUrl == thumbUrl) &&
            (identical(other.bio, bio) || other.bio == bio) &&
            (identical(other.signatureUrl, signatureUrl) ||
                other.signatureUrl == signatureUrl) &&
            (identical(other.idCardPrefix, idCardPrefix) ||
                other.idCardPrefix == idCardPrefix) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, portraitUrl, thumbUrl,
      bio, signatureUrl, idCardPrefix, sortOrder, isActive);

  /// Create a copy of Teacher
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TeacherImplCopyWith<_$TeacherImpl> get copyWith =>
      __$$TeacherImplCopyWithImpl<_$TeacherImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TeacherImplToJson(
      this,
    );
  }
}

abstract class _Teacher implements Teacher {
  const factory _Teacher(
      {required final String id,
      required final LocalisedText name,
      final String? portraitUrl,
      final String? thumbUrl,
      final LocalisedText? bio,
      final String? signatureUrl,
      final String? idCardPrefix,
      final int sortOrder,
      final bool isActive}) = _$TeacherImpl;

  factory _Teacher.fromJson(Map<String, dynamic> json) = _$TeacherImpl.fromJson;

  @override
  String get id;
  @override
  LocalisedText get name;
  @override
  String? get portraitUrl;
  @override
  String? get thumbUrl;
  @override
  LocalisedText? get bio;
  @override
  String? get signatureUrl;

  /// Prefix used for Supporter ID Card unique ids, e.g. `BUD`. Phase 2.
  @override
  String? get idCardPrefix;
  @override
  int get sortOrder;
  @override
  bool get isActive;

  /// Create a copy of Teacher
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TeacherImplCopyWith<_$TeacherImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
