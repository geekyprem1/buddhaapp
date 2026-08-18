// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AppConfig _$AppConfigFromJson(Map<String, dynamic> json) {
  return _AppConfig.fromJson(json);
}

/// @nodoc
mixin _$AppConfig {
  String get minSupportedVersion => throw _privateConstructorUsedError;
  String get latestVersion => throw _privateConstructorUsedError;
  bool get forceUpdate => throw _privateConstructorUsedError;
  bool get maintenanceMode => throw _privateConstructorUsedError;
  LocalisedText get maintenanceMessage => throw _privateConstructorUsedError;
  List<LanguageOption> get languages => throw _privateConstructorUsedError;

  /// Phase 2 (PRD D5).
  bool get adsEnabled => throw _privateConstructorUsedError;

  /// Phase 2 (PRD D4).
  bool get idCardEnabled => throw _privateConstructorUsedError;

  /// Phase 2 (PRD D3).
  bool get liveWallpaperEnabled => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this AppConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AppConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppConfigCopyWith<AppConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppConfigCopyWith<$Res> {
  factory $AppConfigCopyWith(AppConfig value, $Res Function(AppConfig) then) =
      _$AppConfigCopyWithImpl<$Res, AppConfig>;
  @useResult
  $Res call(
      {String minSupportedVersion,
      String latestVersion,
      bool forceUpdate,
      bool maintenanceMode,
      LocalisedText maintenanceMessage,
      List<LanguageOption> languages,
      bool adsEnabled,
      bool idCardEnabled,
      bool liveWallpaperEnabled,
      @TimestampConverter() DateTime? updatedAt});

  $LocalisedTextCopyWith<$Res> get maintenanceMessage;
}

/// @nodoc
class _$AppConfigCopyWithImpl<$Res, $Val extends AppConfig>
    implements $AppConfigCopyWith<$Res> {
  _$AppConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? minSupportedVersion = null,
    Object? latestVersion = null,
    Object? forceUpdate = null,
    Object? maintenanceMode = null,
    Object? maintenanceMessage = null,
    Object? languages = null,
    Object? adsEnabled = null,
    Object? idCardEnabled = null,
    Object? liveWallpaperEnabled = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      minSupportedVersion: null == minSupportedVersion
          ? _value.minSupportedVersion
          : minSupportedVersion // ignore: cast_nullable_to_non_nullable
              as String,
      latestVersion: null == latestVersion
          ? _value.latestVersion
          : latestVersion // ignore: cast_nullable_to_non_nullable
              as String,
      forceUpdate: null == forceUpdate
          ? _value.forceUpdate
          : forceUpdate // ignore: cast_nullable_to_non_nullable
              as bool,
      maintenanceMode: null == maintenanceMode
          ? _value.maintenanceMode
          : maintenanceMode // ignore: cast_nullable_to_non_nullable
              as bool,
      maintenanceMessage: null == maintenanceMessage
          ? _value.maintenanceMessage
          : maintenanceMessage // ignore: cast_nullable_to_non_nullable
              as LocalisedText,
      languages: null == languages
          ? _value.languages
          : languages // ignore: cast_nullable_to_non_nullable
              as List<LanguageOption>,
      adsEnabled: null == adsEnabled
          ? _value.adsEnabled
          : adsEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      idCardEnabled: null == idCardEnabled
          ? _value.idCardEnabled
          : idCardEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      liveWallpaperEnabled: null == liveWallpaperEnabled
          ? _value.liveWallpaperEnabled
          : liveWallpaperEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }

  /// Create a copy of AppConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LocalisedTextCopyWith<$Res> get maintenanceMessage {
    return $LocalisedTextCopyWith<$Res>(_value.maintenanceMessage, (value) {
      return _then(_value.copyWith(maintenanceMessage: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AppConfigImplCopyWith<$Res>
    implements $AppConfigCopyWith<$Res> {
  factory _$$AppConfigImplCopyWith(
          _$AppConfigImpl value, $Res Function(_$AppConfigImpl) then) =
      __$$AppConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String minSupportedVersion,
      String latestVersion,
      bool forceUpdate,
      bool maintenanceMode,
      LocalisedText maintenanceMessage,
      List<LanguageOption> languages,
      bool adsEnabled,
      bool idCardEnabled,
      bool liveWallpaperEnabled,
      @TimestampConverter() DateTime? updatedAt});

  @override
  $LocalisedTextCopyWith<$Res> get maintenanceMessage;
}

/// @nodoc
class __$$AppConfigImplCopyWithImpl<$Res>
    extends _$AppConfigCopyWithImpl<$Res, _$AppConfigImpl>
    implements _$$AppConfigImplCopyWith<$Res> {
  __$$AppConfigImplCopyWithImpl(
      _$AppConfigImpl _value, $Res Function(_$AppConfigImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? minSupportedVersion = null,
    Object? latestVersion = null,
    Object? forceUpdate = null,
    Object? maintenanceMode = null,
    Object? maintenanceMessage = null,
    Object? languages = null,
    Object? adsEnabled = null,
    Object? idCardEnabled = null,
    Object? liveWallpaperEnabled = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_$AppConfigImpl(
      minSupportedVersion: null == minSupportedVersion
          ? _value.minSupportedVersion
          : minSupportedVersion // ignore: cast_nullable_to_non_nullable
              as String,
      latestVersion: null == latestVersion
          ? _value.latestVersion
          : latestVersion // ignore: cast_nullable_to_non_nullable
              as String,
      forceUpdate: null == forceUpdate
          ? _value.forceUpdate
          : forceUpdate // ignore: cast_nullable_to_non_nullable
              as bool,
      maintenanceMode: null == maintenanceMode
          ? _value.maintenanceMode
          : maintenanceMode // ignore: cast_nullable_to_non_nullable
              as bool,
      maintenanceMessage: null == maintenanceMessage
          ? _value.maintenanceMessage
          : maintenanceMessage // ignore: cast_nullable_to_non_nullable
              as LocalisedText,
      languages: null == languages
          ? _value._languages
          : languages // ignore: cast_nullable_to_non_nullable
              as List<LanguageOption>,
      adsEnabled: null == adsEnabled
          ? _value.adsEnabled
          : adsEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      idCardEnabled: null == idCardEnabled
          ? _value.idCardEnabled
          : idCardEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      liveWallpaperEnabled: null == liveWallpaperEnabled
          ? _value.liveWallpaperEnabled
          : liveWallpaperEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AppConfigImpl implements _AppConfig {
  const _$AppConfigImpl(
      {this.minSupportedVersion = '1.0.0',
      this.latestVersion = '1.0.0',
      this.forceUpdate = false,
      this.maintenanceMode = false,
      this.maintenanceMessage = const LocalisedText(),
      final List<LanguageOption> languages = const <LanguageOption>[],
      this.adsEnabled = false,
      this.idCardEnabled = false,
      this.liveWallpaperEnabled = false,
      @TimestampConverter() this.updatedAt})
      : _languages = languages;

  factory _$AppConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppConfigImplFromJson(json);

  @override
  @JsonKey()
  final String minSupportedVersion;
  @override
  @JsonKey()
  final String latestVersion;
  @override
  @JsonKey()
  final bool forceUpdate;
  @override
  @JsonKey()
  final bool maintenanceMode;
  @override
  @JsonKey()
  final LocalisedText maintenanceMessage;
  final List<LanguageOption> _languages;
  @override
  @JsonKey()
  List<LanguageOption> get languages {
    if (_languages is EqualUnmodifiableListView) return _languages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_languages);
  }

  /// Phase 2 (PRD D5).
  @override
  @JsonKey()
  final bool adsEnabled;

  /// Phase 2 (PRD D4).
  @override
  @JsonKey()
  final bool idCardEnabled;

  /// Phase 2 (PRD D3).
  @override
  @JsonKey()
  final bool liveWallpaperEnabled;
  @override
  @TimestampConverter()
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'AppConfig(minSupportedVersion: $minSupportedVersion, latestVersion: $latestVersion, forceUpdate: $forceUpdate, maintenanceMode: $maintenanceMode, maintenanceMessage: $maintenanceMessage, languages: $languages, adsEnabled: $adsEnabled, idCardEnabled: $idCardEnabled, liveWallpaperEnabled: $liveWallpaperEnabled, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppConfigImpl &&
            (identical(other.minSupportedVersion, minSupportedVersion) ||
                other.minSupportedVersion == minSupportedVersion) &&
            (identical(other.latestVersion, latestVersion) ||
                other.latestVersion == latestVersion) &&
            (identical(other.forceUpdate, forceUpdate) ||
                other.forceUpdate == forceUpdate) &&
            (identical(other.maintenanceMode, maintenanceMode) ||
                other.maintenanceMode == maintenanceMode) &&
            (identical(other.maintenanceMessage, maintenanceMessage) ||
                other.maintenanceMessage == maintenanceMessage) &&
            const DeepCollectionEquality()
                .equals(other._languages, _languages) &&
            (identical(other.adsEnabled, adsEnabled) ||
                other.adsEnabled == adsEnabled) &&
            (identical(other.idCardEnabled, idCardEnabled) ||
                other.idCardEnabled == idCardEnabled) &&
            (identical(other.liveWallpaperEnabled, liveWallpaperEnabled) ||
                other.liveWallpaperEnabled == liveWallpaperEnabled) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      minSupportedVersion,
      latestVersion,
      forceUpdate,
      maintenanceMode,
      maintenanceMessage,
      const DeepCollectionEquality().hash(_languages),
      adsEnabled,
      idCardEnabled,
      liveWallpaperEnabled,
      updatedAt);

  /// Create a copy of AppConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppConfigImplCopyWith<_$AppConfigImpl> get copyWith =>
      __$$AppConfigImplCopyWithImpl<_$AppConfigImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AppConfigImplToJson(
      this,
    );
  }
}

abstract class _AppConfig implements AppConfig {
  const factory _AppConfig(
      {final String minSupportedVersion,
      final String latestVersion,
      final bool forceUpdate,
      final bool maintenanceMode,
      final LocalisedText maintenanceMessage,
      final List<LanguageOption> languages,
      final bool adsEnabled,
      final bool idCardEnabled,
      final bool liveWallpaperEnabled,
      @TimestampConverter() final DateTime? updatedAt}) = _$AppConfigImpl;

  factory _AppConfig.fromJson(Map<String, dynamic> json) =
      _$AppConfigImpl.fromJson;

  @override
  String get minSupportedVersion;
  @override
  String get latestVersion;
  @override
  bool get forceUpdate;
  @override
  bool get maintenanceMode;
  @override
  LocalisedText get maintenanceMessage;
  @override
  List<LanguageOption> get languages;

  /// Phase 2 (PRD D5).
  @override
  bool get adsEnabled;

  /// Phase 2 (PRD D4).
  @override
  bool get idCardEnabled;

  /// Phase 2 (PRD D3).
  @override
  bool get liveWallpaperEnabled;
  @override
  @TimestampConverter()
  DateTime? get updatedAt;

  /// Create a copy of AppConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppConfigImplCopyWith<_$AppConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LanguageOption _$LanguageOptionFromJson(Map<String, dynamic> json) {
  return _LanguageOption.fromJson(json);
}

/// @nodoc
mixin _$LanguageOption {
  String get code => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get native => throw _privateConstructorUsedError;

  /// Serializes this LanguageOption to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LanguageOption
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LanguageOptionCopyWith<LanguageOption> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LanguageOptionCopyWith<$Res> {
  factory $LanguageOptionCopyWith(
          LanguageOption value, $Res Function(LanguageOption) then) =
      _$LanguageOptionCopyWithImpl<$Res, LanguageOption>;
  @useResult
  $Res call({String code, String name, String native});
}

/// @nodoc
class _$LanguageOptionCopyWithImpl<$Res, $Val extends LanguageOption>
    implements $LanguageOptionCopyWith<$Res> {
  _$LanguageOptionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LanguageOption
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? name = null,
    Object? native = null,
  }) {
    return _then(_value.copyWith(
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      native: null == native
          ? _value.native
          : native // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LanguageOptionImplCopyWith<$Res>
    implements $LanguageOptionCopyWith<$Res> {
  factory _$$LanguageOptionImplCopyWith(_$LanguageOptionImpl value,
          $Res Function(_$LanguageOptionImpl) then) =
      __$$LanguageOptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String code, String name, String native});
}

/// @nodoc
class __$$LanguageOptionImplCopyWithImpl<$Res>
    extends _$LanguageOptionCopyWithImpl<$Res, _$LanguageOptionImpl>
    implements _$$LanguageOptionImplCopyWith<$Res> {
  __$$LanguageOptionImplCopyWithImpl(
      _$LanguageOptionImpl _value, $Res Function(_$LanguageOptionImpl) _then)
      : super(_value, _then);

  /// Create a copy of LanguageOption
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? name = null,
    Object? native = null,
  }) {
    return _then(_$LanguageOptionImpl(
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      native: null == native
          ? _value.native
          : native // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LanguageOptionImpl implements _LanguageOption {
  const _$LanguageOptionImpl(
      {required this.code, required this.name, required this.native});

  factory _$LanguageOptionImpl.fromJson(Map<String, dynamic> json) =>
      _$$LanguageOptionImplFromJson(json);

  @override
  final String code;
  @override
  final String name;
  @override
  final String native;

  @override
  String toString() {
    return 'LanguageOption(code: $code, name: $name, native: $native)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LanguageOptionImpl &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.native, native) || other.native == native));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, code, name, native);

  /// Create a copy of LanguageOption
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LanguageOptionImplCopyWith<_$LanguageOptionImpl> get copyWith =>
      __$$LanguageOptionImplCopyWithImpl<_$LanguageOptionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LanguageOptionImplToJson(
      this,
    );
  }
}

abstract class _LanguageOption implements LanguageOption {
  const factory _LanguageOption(
      {required final String code,
      required final String name,
      required final String native}) = _$LanguageOptionImpl;

  factory _LanguageOption.fromJson(Map<String, dynamic> json) =
      _$LanguageOptionImpl.fromJson;

  @override
  String get code;
  @override
  String get name;
  @override
  String get native;

  /// Create a copy of LanguageOption
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LanguageOptionImplCopyWith<_$LanguageOptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
