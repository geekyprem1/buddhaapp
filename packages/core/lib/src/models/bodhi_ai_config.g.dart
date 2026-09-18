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
      freeDailyMessages: (json['freeDailyMessages'] as num?)?.toInt() ?? 15,
      paidDailyMessages: (json['paidDailyMessages'] as num?)?.toInt() ?? 120,
      maxTokens: (json['maxTokens'] as num?)?.toInt() ?? 300,
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.4,
      updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
    );

Map<String, dynamic> _$$BodhiAiConfigImplToJson(_$BodhiAiConfigImpl instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'model': instance.model,
      'systemInstruction': instance.systemInstruction.toJson(),
      'freeDailyMessages': instance.freeDailyMessages,
      'paidDailyMessages': instance.paidDailyMessages,
      'maxTokens': instance.maxTokens,
      'temperature': instance.temperature,
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
    };
