// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_counters.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ContentCountersImpl _$$ContentCountersImplFromJson(Map json) =>
    _$ContentCountersImpl(
      views: (json['views'] as num?)?.toInt() ?? 0,
      downloads: (json['downloads'] as num?)?.toInt() ?? 0,
      shares: (json['shares'] as num?)?.toInt() ?? 0,
      plays: (json['plays'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$ContentCountersImplToJson(
        _$ContentCountersImpl instance) =>
    <String, dynamic>{
      'views': instance.views,
      'downloads': instance.downloads,
      'shares': instance.shares,
      'plays': instance.plays,
    };
