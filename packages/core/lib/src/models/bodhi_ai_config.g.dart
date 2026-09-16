// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bodhi_ai_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BodhiAiConfigImpl _$$BodhiAiConfigImplFromJson(Map json) =>
    _$BodhiAiConfigImpl(
      enabled: json['enabled'] as bool? ?? false,
      model: json['model'] as String? ?? 'deepseek/deepseek-v4-flash-0731',
      systemInstruction: json['systemInstruction'] == null
          ? const LocalisedText()
          : LocalisedText.fromJson(
              Map<String, dynamic>.from(json['systemInstruction'] as Map)),
      freeDailySeconds: (json['freeDailySeconds'] as num?)?.toInt() ?? 210,
      paidDailySeconds: (json['paidDailySeconds'] as num?)?.toInt() ?? 1800,
      freeDailyMessages: (json['freeDailyMessages'] as num?)?.toInt() ?? 15,
      paidDailyMessages: (json['paidDailyMessages'] as num?)?.toInt() ?? 120,
      maxTokens: (json['maxTokens'] as num?)?.toInt() ?? 700,
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.4,
      updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
    );

Map<String, dynamic> _$$BodhiAiConfigImplToJson(_$BodhiAiConfigImpl instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'model': instance.model,
      'systemInstruction': instance.systemInstruction.toJson(),
      'freeDailySeconds': instance.freeDailySeconds,
      'paidDailySeconds': instance.paidDailySeconds,
      'freeDailyMessages': instance.freeDailyMessages,
      'paidDailyMessages': instance.paidDailyMessages,
      'maxTokens': instance.maxTokens,
      'temperature': instance.temperature,
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
    };
