// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bodhi_ai_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

BodhiAiConfig _$BodhiAiConfigFromJson(Map<String, dynamic> json) {
  return _BodhiAiConfig.fromJson(json);
}

/// @nodoc
mixin _$BodhiAiConfig {
  bool get enabled => throw _privateConstructorUsedError;

  /// OpenRouter model slug.
  ///
  /// Deliberately a pinned, dated checkpoint. Do **not** set this to a
  /// `~vendor/model-latest` alias — an alias silently re-points to a new
  /// checkpoint, so a tuned [systemInstruction] would one day run against a
  /// model it was never tested on.
  String get model => throw _privateConstructorUsedError;

  /// Tone and style guidance, per locale.
  ///
  /// This does **not** carry the Buddhism-only restriction. That rule is
  /// hardcoded in the Function and prepended to whatever is stored here, so
  /// an admin cannot remove it from this field. Empty means "use the
  /// Function's built-in default tone".
  LocalisedText get systemInstruction => throw _privateConstructorUsedError;

  /// Daily chat allowance in seconds. 210 = 3 min 30 s.
  int get freeDailySeconds => throw _privateConstructorUsedError;
  int get paidDailySeconds => throw _privateConstructorUsedError;

  /// Cost guards, independent of the minute quota. Under normal use the user
  /// only ever sees the minute counter; these should only bite for outliers.
  /// If they start firing for ordinary users, that is the signal that
  /// minutes was the wrong meter.
  int get freeDailyMessages => throw _privateConstructorUsedError;
  int get paidDailyMessages => throw _privateConstructorUsedError;

  /// Per-reply output ceiling, so one "write me an essay" prompt cannot
  /// produce an outsized bill.
  int get maxTokens => throw _privateConstructorUsedError;

  /// Lower is more factual. Doctrinal answers should not be inventive.
  double get temperature => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this BodhiAiConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BodhiAiConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BodhiAiConfigCopyWith<BodhiAiConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BodhiAiConfigCopyWith<$Res> {
  factory $BodhiAiConfigCopyWith(
          BodhiAiConfig value, $Res Function(BodhiAiConfig) then) =
      _$BodhiAiConfigCopyWithImpl<$Res, BodhiAiConfig>;
  @useResult
  $Res call(
      {bool enabled,
      String model,
      LocalisedText systemInstruction,
      int freeDailySeconds,
      int paidDailySeconds,
      int freeDailyMessages,
      int paidDailyMessages,
      int maxTokens,
      double temperature,
      @TimestampConverter() DateTime? updatedAt});

  $LocalisedTextCopyWith<$Res> get systemInstruction;
}

/// @nodoc
class _$BodhiAiConfigCopyWithImpl<$Res, $Val extends BodhiAiConfig>
    implements $BodhiAiConfigCopyWith<$Res> {
  _$BodhiAiConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BodhiAiConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enabled = null,
    Object? model = null,
    Object? systemInstruction = null,
    Object? freeDailySeconds = null,
    Object? paidDailySeconds = null,
    Object? freeDailyMessages = null,
    Object? paidDailyMessages = null,
    Object? maxTokens = null,
    Object? temperature = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      enabled: null == enabled
          ? _value.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool,
      model: null == model
          ? _value.model
          : model // ignore: cast_nullable_to_non_nullable
              as String,
      systemInstruction: null == systemInstruction
          ? _value.systemInstruction
          : systemInstruction // ignore: cast_nullable_to_non_nullable
              as LocalisedText,
      freeDailySeconds: null == freeDailySeconds
          ? _value.freeDailySeconds
          : freeDailySeconds // ignore: cast_nullable_to_non_nullable
              as int,
      paidDailySeconds: null == paidDailySeconds
          ? _value.paidDailySeconds
          : paidDailySeconds // ignore: cast_nullable_to_non_nullable
              as int,
      freeDailyMessages: null == freeDailyMessages
          ? _value.freeDailyMessages
          : freeDailyMessages // ignore: cast_nullable_to_non_nullable
              as int,
      paidDailyMessages: null == paidDailyMessages
          ? _value.paidDailyMessages
          : paidDailyMessages // ignore: cast_nullable_to_non_nullable
              as int,
      maxTokens: null == maxTokens
          ? _value.maxTokens
          : maxTokens // ignore: cast_nullable_to_non_nullable
              as int,
      temperature: null == temperature
          ? _value.temperature
          : temperature // ignore: cast_nullable_to_non_nullable
              as double,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }

  /// Create a copy of BodhiAiConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LocalisedTextCopyWith<$Res> get systemInstruction {
    return $LocalisedTextCopyWith<$Res>(_value.systemInstruction, (value) {
      return _then(_value.copyWith(systemInstruction: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$BodhiAiConfigImplCopyWith<$Res>
    implements $BodhiAiConfigCopyWith<$Res> {
  factory _$$BodhiAiConfigImplCopyWith(
          _$BodhiAiConfigImpl value, $Res Function(_$BodhiAiConfigImpl) then) =
      __$$BodhiAiConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool enabled,
      String model,
      LocalisedText systemInstruction,
      int freeDailySeconds,
      int paidDailySeconds,
      int freeDailyMessages,
      int paidDailyMessages,
      int maxTokens,
      double temperature,
      @TimestampConverter() DateTime? updatedAt});

  @override
  $LocalisedTextCopyWith<$Res> get systemInstruction;
}

/// @nodoc
class __$$BodhiAiConfigImplCopyWithImpl<$Res>
    extends _$BodhiAiConfigCopyWithImpl<$Res, _$BodhiAiConfigImpl>
    implements _$$BodhiAiConfigImplCopyWith<$Res> {
  __$$BodhiAiConfigImplCopyWithImpl(
      _$BodhiAiConfigImpl _value, $Res Function(_$BodhiAiConfigImpl) _then)
      : super(_value, _then);

  /// Create a copy of BodhiAiConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enabled = null,
    Object? model = null,
    Object? systemInstruction = null,
    Object? freeDailySeconds = null,
    Object? paidDailySeconds = null,
    Object? freeDailyMessages = null,
    Object? paidDailyMessages = null,
    Object? maxTokens = null,
    Object? temperature = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_$BodhiAiConfigImpl(
      enabled: null == enabled
          ? _value.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool,
      model: null == model
          ? _value.model
          : model // ignore: cast_nullable_to_non_nullable
              as String,
      systemInstruction: null == systemInstruction
          ? _value.systemInstruction
          : systemInstruction // ignore: cast_nullable_to_non_nullable
              as LocalisedText,
      freeDailySeconds: null == freeDailySeconds
          ? _value.freeDailySeconds
          : freeDailySeconds // ignore: cast_nullable_to_non_nullable
              as int,
      paidDailySeconds: null == paidDailySeconds
          ? _value.paidDailySeconds
          : paidDailySeconds // ignore: cast_nullable_to_non_nullable
              as int,
      freeDailyMessages: null == freeDailyMessages
          ? _value.freeDailyMessages
          : freeDailyMessages // ignore: cast_nullable_to_non_nullable
              as int,
      paidDailyMessages: null == paidDailyMessages
          ? _value.paidDailyMessages
          : paidDailyMessages // ignore: cast_nullable_to_non_nullable
              as int,
      maxTokens: null == maxTokens
          ? _value.maxTokens
          : maxTokens // ignore: cast_nullable_to_non_nullable
              as int,
      temperature: null == temperature
          ? _value.temperature
          : temperature // ignore: cast_nullable_to_non_nullable
              as double,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BodhiAiConfigImpl implements _BodhiAiConfig {
  const _$BodhiAiConfigImpl(
      {this.enabled = false,
      this.model = 'deepseek/deepseek-v4-flash-0731',
      this.systemInstruction = const LocalisedText(),
      this.freeDailySeconds = 210,
      this.paidDailySeconds = 1800,
      this.freeDailyMessages = 15,
      this.paidDailyMessages = 120,
      this.maxTokens = 700,
      this.temperature = 0.4,
      @TimestampConverter() this.updatedAt});

  factory _$BodhiAiConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$BodhiAiConfigImplFromJson(json);

  @override
  @JsonKey()
  final bool enabled;

  /// OpenRouter model slug.
  ///
  /// Deliberately a pinned, dated checkpoint. Do **not** set this to a
  /// `~vendor/model-latest` alias — an alias silently re-points to a new
  /// checkpoint, so a tuned [systemInstruction] would one day run against a
  /// model it was never tested on.
  @override
  @JsonKey()
  final String model;

  /// Tone and style guidance, per locale.
  ///
  /// This does **not** carry the Buddhism-only restriction. That rule is
  /// hardcoded in the Function and prepended to whatever is stored here, so
  /// an admin cannot remove it from this field. Empty means "use the
  /// Function's built-in default tone".
  @override
  @JsonKey()
  final LocalisedText systemInstruction;

  /// Daily chat allowance in seconds. 210 = 3 min 30 s.
  @override
  @JsonKey()
  final int freeDailySeconds;
  @override
  @JsonKey()
  final int paidDailySeconds;

  /// Cost guards, independent of the minute quota. Under normal use the user
  /// only ever sees the minute counter; these should only bite for outliers.
  /// If they start firing for ordinary users, that is the signal that
  /// minutes was the wrong meter.
  @override
  @JsonKey()
  final int freeDailyMessages;
  @override
  @JsonKey()
  final int paidDailyMessages;

  /// Per-reply output ceiling, so one "write me an essay" prompt cannot
  /// produce an outsized bill.
  @override
  @JsonKey()
  final int maxTokens;

  /// Lower is more factual. Doctrinal answers should not be inventive.
  @override
  @JsonKey()
  final double temperature;
  @override
  @TimestampConverter()
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'BodhiAiConfig(enabled: $enabled, model: $model, systemInstruction: $systemInstruction, freeDailySeconds: $freeDailySeconds, paidDailySeconds: $paidDailySeconds, freeDailyMessages: $freeDailyMessages, paidDailyMessages: $paidDailyMessages, maxTokens: $maxTokens, temperature: $temperature, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BodhiAiConfigImpl &&
            (identical(other.enabled, enabled) || other.enabled == enabled) &&
            (identical(other.model, model) || other.model == model) &&
            (identical(other.systemInstruction, systemInstruction) ||
                other.systemInstruction == systemInstruction) &&
            (identical(other.freeDailySeconds, freeDailySeconds) ||
                other.freeDailySeconds == freeDailySeconds) &&
            (identical(other.paidDailySeconds, paidDailySeconds) ||
                other.paidDailySeconds == paidDailySeconds) &&
            (identical(other.freeDailyMessages, freeDailyMessages) ||
                other.freeDailyMessages == freeDailyMessages) &&
            (identical(other.paidDailyMessages, paidDailyMessages) ||
                other.paidDailyMessages == paidDailyMessages) &&
            (identical(other.maxTokens, maxTokens) ||
                other.maxTokens == maxTokens) &&
            (identical(other.temperature, temperature) ||
                other.temperature == temperature) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      enabled,
      model,
      systemInstruction,
      freeDailySeconds,
      paidDailySeconds,
      freeDailyMessages,
      paidDailyMessages,
      maxTokens,
      temperature,
      updatedAt);

  /// Create a copy of BodhiAiConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BodhiAiConfigImplCopyWith<_$BodhiAiConfigImpl> get copyWith =>
      __$$BodhiAiConfigImplCopyWithImpl<_$BodhiAiConfigImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BodhiAiConfigImplToJson(
      this,
    );
  }
}

abstract class _BodhiAiConfig implements BodhiAiConfig {
  const factory _BodhiAiConfig(
      {final bool enabled,
      final String model,
      final LocalisedText systemInstruction,
      final int freeDailySeconds,
      final int paidDailySeconds,
      final int freeDailyMessages,
      final int paidDailyMessages,
      final int maxTokens,
      final double temperature,
      @TimestampConverter() final DateTime? updatedAt}) = _$BodhiAiConfigImpl;

  factory _BodhiAiConfig.fromJson(Map<String, dynamic> json) =
      _$BodhiAiConfigImpl.fromJson;

  @override
  bool get enabled;

  /// OpenRouter model slug.
  ///
  /// Deliberately a pinned, dated checkpoint. Do **not** set this to a
  /// `~vendor/model-latest` alias — an alias silently re-points to a new
  /// checkpoint, so a tuned [systemInstruction] would one day run against a
  /// model it was never tested on.
  @override
  String get model;

  /// Tone and style guidance, per locale.
  ///
  /// This does **not** carry the Buddhism-only restriction. That rule is
  /// hardcoded in the Function and prepended to whatever is stored here, so
  /// an admin cannot remove it from this field. Empty means "use the
  /// Function's built-in default tone".
  @override
  LocalisedText get systemInstruction;

  /// Daily chat allowance in seconds. 210 = 3 min 30 s.
  @override
  int get freeDailySeconds;
  @override
  int get paidDailySeconds;

  /// Cost guards, independent of the minute quota. Under normal use the user
  /// only ever sees the minute counter; these should only bite for outliers.
  /// If they start firing for ordinary users, that is the signal that
  /// minutes was the wrong meter.
  @override
  int get freeDailyMessages;
  @override
  int get paidDailyMessages;

  /// Per-reply output ceiling, so one "write me an essay" prompt cannot
  /// produce an outsized bill.
  @override
  int get maxTokens;

  /// Lower is more factual. Doctrinal answers should not be inventive.
  @override
  double get temperature;
  @override
  @TimestampConverter()
  DateTime? get updatedAt;

  /// Create a copy of BodhiAiConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BodhiAiConfigImplCopyWith<_$BodhiAiConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
