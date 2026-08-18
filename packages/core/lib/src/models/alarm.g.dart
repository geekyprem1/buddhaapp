// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alarm.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AlarmImpl _$$AlarmImplFromJson(Map json) => _$AlarmImpl(
      id: json['id'] as String,
      timeHour: (json['timeHour'] as num?)?.toInt() ?? 6,
      timeMinute: (json['timeMinute'] as num?)?.toInt() ?? 0,
      repeatDays: (json['repeatDays'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const <int>[],
      isEveryday: json['isEveryday'] as bool? ?? true,
      prarthanaId: json['prarthanaId'] as String?,
      prarthanaLocalPath: json['prarthanaLocalPath'] as String?,
      isEnabled: json['isEnabled'] as bool? ?? true,
      label: json['label'] as String? ?? 'Daily Prarthana',
      snoozeMinutes: (json['snoozeMinutes'] as num?)?.toInt() ?? 10,
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
    );

Map<String, dynamic> _$$AlarmImplToJson(_$AlarmImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'timeHour': instance.timeHour,
      'timeMinute': instance.timeMinute,
      'repeatDays': instance.repeatDays,
      'isEveryday': instance.isEveryday,
      'prarthanaId': instance.prarthanaId,
      'prarthanaLocalPath': instance.prarthanaLocalPath,
      'isEnabled': instance.isEnabled,
      'label': instance.label,
      'snoozeMinutes': instance.snoozeMinutes,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
    };
