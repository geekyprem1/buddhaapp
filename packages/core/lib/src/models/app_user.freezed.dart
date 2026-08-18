// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AppUser _$AppUserFromJson(Map<String, dynamic> json) {
  return _AppUser.fromJson(json);
}

/// @nodoc
mixin _$AppUser {
  String get uid => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String? get photoUrl => throw _privateConstructorUsedError;
  String get language => throw _privateConstructorUsedError;
  List<String> get selectedTeachers => throw _privateConstructorUsedError;

  /// `phone` | `google`
  String get authMethod => throw _privateConstructorUsedError;

  /// `language` | `person_info` | `teacher` | `complete`
  String get onboardingStep => throw _privateConstructorUsedError;
  List<String> get fcmTokens => throw _privateConstructorUsedError;
  NotificationPrefs get notificationPrefs => throw _privateConstructorUsedError;
  bool get isBlocked => throw _privateConstructorUsedError;
  String get platform => throw _privateConstructorUsedError;
  String? get appVersion => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get lastActiveAt => throw _privateConstructorUsedError;

  /// Serializes this AppUser to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AppUser
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppUserCopyWith<AppUser> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppUserCopyWith<$Res> {
  factory $AppUserCopyWith(AppUser value, $Res Function(AppUser) then) =
      _$AppUserCopyWithImpl<$Res, AppUser>;
  @useResult
  $Res call(
      {String uid,
      String name,
      String? phone,
      String? email,
      String? photoUrl,
      String language,
      List<String> selectedTeachers,
      String authMethod,
      String onboardingStep,
      List<String> fcmTokens,
      NotificationPrefs notificationPrefs,
      bool isBlocked,
      String platform,
      String? appVersion,
      @TimestampConverter() DateTime? createdAt,
      @TimestampConverter() DateTime? lastActiveAt});

  $NotificationPrefsCopyWith<$Res> get notificationPrefs;
}

/// @nodoc
class _$AppUserCopyWithImpl<$Res, $Val extends AppUser>
    implements $AppUserCopyWith<$Res> {
  _$AppUserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppUser
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? name = null,
    Object? phone = freezed,
    Object? email = freezed,
    Object? photoUrl = freezed,
    Object? language = null,
    Object? selectedTeachers = null,
    Object? authMethod = null,
    Object? onboardingStep = null,
    Object? fcmTokens = null,
    Object? notificationPrefs = null,
    Object? isBlocked = null,
    Object? platform = null,
    Object? appVersion = freezed,
    Object? createdAt = freezed,
    Object? lastActiveAt = freezed,
  }) {
    return _then(_value.copyWith(
      uid: null == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      language: null == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String,
      selectedTeachers: null == selectedTeachers
          ? _value.selectedTeachers
          : selectedTeachers // ignore: cast_nullable_to_non_nullable
              as List<String>,
      authMethod: null == authMethod
          ? _value.authMethod
          : authMethod // ignore: cast_nullable_to_non_nullable
              as String,
      onboardingStep: null == onboardingStep
          ? _value.onboardingStep
          : onboardingStep // ignore: cast_nullable_to_non_nullable
              as String,
      fcmTokens: null == fcmTokens
          ? _value.fcmTokens
          : fcmTokens // ignore: cast_nullable_to_non_nullable
              as List<String>,
      notificationPrefs: null == notificationPrefs
          ? _value.notificationPrefs
          : notificationPrefs // ignore: cast_nullable_to_non_nullable
              as NotificationPrefs,
      isBlocked: null == isBlocked
          ? _value.isBlocked
          : isBlocked // ignore: cast_nullable_to_non_nullable
              as bool,
      platform: null == platform
          ? _value.platform
          : platform // ignore: cast_nullable_to_non_nullable
              as String,
      appVersion: freezed == appVersion
          ? _value.appVersion
          : appVersion // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastActiveAt: freezed == lastActiveAt
          ? _value.lastActiveAt
          : lastActiveAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }

  /// Create a copy of AppUser
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $NotificationPrefsCopyWith<$Res> get notificationPrefs {
    return $NotificationPrefsCopyWith<$Res>(_value.notificationPrefs, (value) {
      return _then(_value.copyWith(notificationPrefs: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AppUserImplCopyWith<$Res> implements $AppUserCopyWith<$Res> {
  factory _$$AppUserImplCopyWith(
          _$AppUserImpl value, $Res Function(_$AppUserImpl) then) =
      __$$AppUserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String uid,
      String name,
      String? phone,
      String? email,
      String? photoUrl,
      String language,
      List<String> selectedTeachers,
      String authMethod,
      String onboardingStep,
      List<String> fcmTokens,
      NotificationPrefs notificationPrefs,
      bool isBlocked,
      String platform,
      String? appVersion,
      @TimestampConverter() DateTime? createdAt,
      @TimestampConverter() DateTime? lastActiveAt});

  @override
  $NotificationPrefsCopyWith<$Res> get notificationPrefs;
}

/// @nodoc
class __$$AppUserImplCopyWithImpl<$Res>
    extends _$AppUserCopyWithImpl<$Res, _$AppUserImpl>
    implements _$$AppUserImplCopyWith<$Res> {
  __$$AppUserImplCopyWithImpl(
      _$AppUserImpl _value, $Res Function(_$AppUserImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppUser
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? name = null,
    Object? phone = freezed,
    Object? email = freezed,
    Object? photoUrl = freezed,
    Object? language = null,
    Object? selectedTeachers = null,
    Object? authMethod = null,
    Object? onboardingStep = null,
    Object? fcmTokens = null,
    Object? notificationPrefs = null,
    Object? isBlocked = null,
    Object? platform = null,
    Object? appVersion = freezed,
    Object? createdAt = freezed,
    Object? lastActiveAt = freezed,
  }) {
    return _then(_$AppUserImpl(
      uid: null == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      language: null == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String,
      selectedTeachers: null == selectedTeachers
          ? _value._selectedTeachers
          : selectedTeachers // ignore: cast_nullable_to_non_nullable
              as List<String>,
      authMethod: null == authMethod
          ? _value.authMethod
          : authMethod // ignore: cast_nullable_to_non_nullable
              as String,
      onboardingStep: null == onboardingStep
          ? _value.onboardingStep
          : onboardingStep // ignore: cast_nullable_to_non_nullable
              as String,
      fcmTokens: null == fcmTokens
          ? _value._fcmTokens
          : fcmTokens // ignore: cast_nullable_to_non_nullable
              as List<String>,
      notificationPrefs: null == notificationPrefs
          ? _value.notificationPrefs
          : notificationPrefs // ignore: cast_nullable_to_non_nullable
              as NotificationPrefs,
      isBlocked: null == isBlocked
          ? _value.isBlocked
          : isBlocked // ignore: cast_nullable_to_non_nullable
              as bool,
      platform: null == platform
          ? _value.platform
          : platform // ignore: cast_nullable_to_non_nullable
              as String,
      appVersion: freezed == appVersion
          ? _value.appVersion
          : appVersion // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastActiveAt: freezed == lastActiveAt
          ? _value.lastActiveAt
          : lastActiveAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AppUserImpl implements _AppUser {
  const _$AppUserImpl(
      {required this.uid,
      this.name = '',
      this.phone,
      this.email,
      this.photoUrl,
      this.language = 'en',
      final List<String> selectedTeachers = const <String>[],
      this.authMethod = 'phone',
      this.onboardingStep = 'language',
      final List<String> fcmTokens = const <String>[],
      this.notificationPrefs = const NotificationPrefs(),
      this.isBlocked = false,
      this.platform = 'android',
      this.appVersion,
      @TimestampConverter() this.createdAt,
      @TimestampConverter() this.lastActiveAt})
      : _selectedTeachers = selectedTeachers,
        _fcmTokens = fcmTokens;

  factory _$AppUserImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppUserImplFromJson(json);

  @override
  final String uid;
  @override
  @JsonKey()
  final String name;
  @override
  final String? phone;
  @override
  final String? email;
  @override
  final String? photoUrl;
  @override
  @JsonKey()
  final String language;
  final List<String> _selectedTeachers;
  @override
  @JsonKey()
  List<String> get selectedTeachers {
    if (_selectedTeachers is EqualUnmodifiableListView)
      return _selectedTeachers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_selectedTeachers);
  }

  /// `phone` | `google`
  @override
  @JsonKey()
  final String authMethod;

  /// `language` | `person_info` | `teacher` | `complete`
  @override
  @JsonKey()
  final String onboardingStep;
  final List<String> _fcmTokens;
  @override
  @JsonKey()
  List<String> get fcmTokens {
    if (_fcmTokens is EqualUnmodifiableListView) return _fcmTokens;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_fcmTokens);
  }

  @override
  @JsonKey()
  final NotificationPrefs notificationPrefs;
  @override
  @JsonKey()
  final bool isBlocked;
  @override
  @JsonKey()
  final String platform;
  @override
  final String? appVersion;
  @override
  @TimestampConverter()
  final DateTime? createdAt;
  @override
  @TimestampConverter()
  final DateTime? lastActiveAt;

  @override
  String toString() {
    return 'AppUser(uid: $uid, name: $name, phone: $phone, email: $email, photoUrl: $photoUrl, language: $language, selectedTeachers: $selectedTeachers, authMethod: $authMethod, onboardingStep: $onboardingStep, fcmTokens: $fcmTokens, notificationPrefs: $notificationPrefs, isBlocked: $isBlocked, platform: $platform, appVersion: $appVersion, createdAt: $createdAt, lastActiveAt: $lastActiveAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppUserImpl &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            (identical(other.language, language) ||
                other.language == language) &&
            const DeepCollectionEquality()
                .equals(other._selectedTeachers, _selectedTeachers) &&
            (identical(other.authMethod, authMethod) ||
                other.authMethod == authMethod) &&
            (identical(other.onboardingStep, onboardingStep) ||
                other.onboardingStep == onboardingStep) &&
            const DeepCollectionEquality()
                .equals(other._fcmTokens, _fcmTokens) &&
            (identical(other.notificationPrefs, notificationPrefs) ||
                other.notificationPrefs == notificationPrefs) &&
            (identical(other.isBlocked, isBlocked) ||
                other.isBlocked == isBlocked) &&
            (identical(other.platform, platform) ||
                other.platform == platform) &&
            (identical(other.appVersion, appVersion) ||
                other.appVersion == appVersion) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.lastActiveAt, lastActiveAt) ||
                other.lastActiveAt == lastActiveAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      uid,
      name,
      phone,
      email,
      photoUrl,
      language,
      const DeepCollectionEquality().hash(_selectedTeachers),
      authMethod,
      onboardingStep,
      const DeepCollectionEquality().hash(_fcmTokens),
      notificationPrefs,
      isBlocked,
      platform,
      appVersion,
      createdAt,
      lastActiveAt);

  /// Create a copy of AppUser
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppUserImplCopyWith<_$AppUserImpl> get copyWith =>
      __$$AppUserImplCopyWithImpl<_$AppUserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AppUserImplToJson(
      this,
    );
  }
}

abstract class _AppUser implements AppUser {
  const factory _AppUser(
      {required final String uid,
      final String name,
      final String? phone,
      final String? email,
      final String? photoUrl,
      final String language,
      final List<String> selectedTeachers,
      final String authMethod,
      final String onboardingStep,
      final List<String> fcmTokens,
      final NotificationPrefs notificationPrefs,
      final bool isBlocked,
      final String platform,
      final String? appVersion,
      @TimestampConverter() final DateTime? createdAt,
      @TimestampConverter() final DateTime? lastActiveAt}) = _$AppUserImpl;

  factory _AppUser.fromJson(Map<String, dynamic> json) = _$AppUserImpl.fromJson;

  @override
  String get uid;
  @override
  String get name;
  @override
  String? get phone;
  @override
  String? get email;
  @override
  String? get photoUrl;
  @override
  String get language;
  @override
  List<String> get selectedTeachers;

  /// `phone` | `google`
  @override
  String get authMethod;

  /// `language` | `person_info` | `teacher` | `complete`
  @override
  String get onboardingStep;
  @override
  List<String> get fcmTokens;
  @override
  NotificationPrefs get notificationPrefs;
  @override
  bool get isBlocked;
  @override
  String get platform;
  @override
  String? get appVersion;
  @override
  @TimestampConverter()
  DateTime? get createdAt;
  @override
  @TimestampConverter()
  DateTime? get lastActiveAt;

  /// Create a copy of AppUser
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppUserImplCopyWith<_$AppUserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

NotificationPrefs _$NotificationPrefsFromJson(Map<String, dynamic> json) {
  return _NotificationPrefs.fromJson(json);
}

/// @nodoc
mixin _$NotificationPrefs {
  bool get push => throw _privateConstructorUsedError;
  bool get prarthana => throw _privateConstructorUsedError;

  /// Serializes this NotificationPrefs to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NotificationPrefs
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationPrefsCopyWith<NotificationPrefs> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationPrefsCopyWith<$Res> {
  factory $NotificationPrefsCopyWith(
          NotificationPrefs value, $Res Function(NotificationPrefs) then) =
      _$NotificationPrefsCopyWithImpl<$Res, NotificationPrefs>;
  @useResult
  $Res call({bool push, bool prarthana});
}

/// @nodoc
class _$NotificationPrefsCopyWithImpl<$Res, $Val extends NotificationPrefs>
    implements $NotificationPrefsCopyWith<$Res> {
  _$NotificationPrefsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationPrefs
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? push = null,
    Object? prarthana = null,
  }) {
    return _then(_value.copyWith(
      push: null == push
          ? _value.push
          : push // ignore: cast_nullable_to_non_nullable
              as bool,
      prarthana: null == prarthana
          ? _value.prarthana
          : prarthana // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NotificationPrefsImplCopyWith<$Res>
    implements $NotificationPrefsCopyWith<$Res> {
  factory _$$NotificationPrefsImplCopyWith(_$NotificationPrefsImpl value,
          $Res Function(_$NotificationPrefsImpl) then) =
      __$$NotificationPrefsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool push, bool prarthana});
}

/// @nodoc
class __$$NotificationPrefsImplCopyWithImpl<$Res>
    extends _$NotificationPrefsCopyWithImpl<$Res, _$NotificationPrefsImpl>
    implements _$$NotificationPrefsImplCopyWith<$Res> {
  __$$NotificationPrefsImplCopyWithImpl(_$NotificationPrefsImpl _value,
      $Res Function(_$NotificationPrefsImpl) _then)
      : super(_value, _then);

  /// Create a copy of NotificationPrefs
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? push = null,
    Object? prarthana = null,
  }) {
    return _then(_$NotificationPrefsImpl(
      push: null == push
          ? _value.push
          : push // ignore: cast_nullable_to_non_nullable
              as bool,
      prarthana: null == prarthana
          ? _value.prarthana
          : prarthana // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationPrefsImpl implements _NotificationPrefs {
  const _$NotificationPrefsImpl({this.push = true, this.prarthana = true});

  factory _$NotificationPrefsImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationPrefsImplFromJson(json);

  @override
  @JsonKey()
  final bool push;
  @override
  @JsonKey()
  final bool prarthana;

  @override
  String toString() {
    return 'NotificationPrefs(push: $push, prarthana: $prarthana)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationPrefsImpl &&
            (identical(other.push, push) || other.push == push) &&
            (identical(other.prarthana, prarthana) ||
                other.prarthana == prarthana));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, push, prarthana);

  /// Create a copy of NotificationPrefs
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationPrefsImplCopyWith<_$NotificationPrefsImpl> get copyWith =>
      __$$NotificationPrefsImplCopyWithImpl<_$NotificationPrefsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationPrefsImplToJson(
      this,
    );
  }
}

abstract class _NotificationPrefs implements NotificationPrefs {
  const factory _NotificationPrefs({final bool push, final bool prarthana}) =
      _$NotificationPrefsImpl;

  factory _NotificationPrefs.fromJson(Map<String, dynamic> json) =
      _$NotificationPrefsImpl.fromJson;

  @override
  bool get push;
  @override
  bool get prarthana;

  /// Create a copy of NotificationPrefs
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationPrefsImplCopyWith<_$NotificationPrefsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
