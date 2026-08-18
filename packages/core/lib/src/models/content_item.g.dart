// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ContentItemImpl _$$ContentItemImplFromJson(Map json) => _$ContentItemImpl(
      id: json['id'] as String,
      type: json['type'] as String,
      teacherIds: (json['teacherIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      categoryId: json['categoryId'] as String?,
      title: LocalisedText.fromJson(
          Map<String, dynamic>.from(json['title'] as Map)),
      artist: json['artist'] as String?,
      mediaUrl: json['mediaUrl'] as String?,
      thumbUrl: json['thumbUrl'] as String?,
      storagePath: json['storagePath'] as String?,
      language: json['language'] as String?,
      status: json['status'] as String? ?? 'draft',
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      isFeatured: json['isFeatured'] as bool? ?? false,
      isPremium: json['isPremium'] as bool? ?? false,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const <String>[],
      counters: json['counters'] == null
          ? const ContentCounters()
          : ContentCounters.fromJson(
              Map<String, dynamic>.from(json['counters'] as Map)),
      source: json['source'] as String?,
      licence: json['licence'] as String?,
      publishAt: const TimestampConverter().fromJson(json['publishAt']),
      expireAt: const TimestampConverter().fromJson(json['expireAt']),
      createdBy: json['createdBy'] as String?,
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
      deletedAt: const TimestampConverter().fromJson(json['deletedAt']),
      wallpaper: json['wallpaper'] == null
          ? null
          : WallpaperMeta.fromJson(
              Map<String, dynamic>.from(json['wallpaper'] as Map)),
      audio: json['audio'] == null
          ? null
          : AudioMeta.fromJson(Map<String, dynamic>.from(json['audio'] as Map)),
      statusMeta: json['statusMeta'] == null
          ? null
          : StatusMeta.fromJson(
              Map<String, dynamic>.from(json['statusMeta'] as Map)),
    );

Map<String, dynamic> _$$ContentItemImplToJson(_$ContentItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'teacherIds': instance.teacherIds,
      'categoryId': instance.categoryId,
      'title': instance.title.toJson(),
      'artist': instance.artist,
      'mediaUrl': instance.mediaUrl,
      'thumbUrl': instance.thumbUrl,
      'storagePath': instance.storagePath,
      'language': instance.language,
      'status': instance.status,
      'sortOrder': instance.sortOrder,
      'isFeatured': instance.isFeatured,
      'isPremium': instance.isPremium,
      'tags': instance.tags,
      'counters': instance.counters.toJson(),
      'source': instance.source,
      'licence': instance.licence,
      'publishAt': const TimestampConverter().toJson(instance.publishAt),
      'expireAt': const TimestampConverter().toJson(instance.expireAt),
      'createdBy': instance.createdBy,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
      'deletedAt': const TimestampConverter().toJson(instance.deletedAt),
      'wallpaper': instance.wallpaper?.toJson(),
      'audio': instance.audio?.toJson(),
      'statusMeta': instance.statusMeta?.toJson(),
    };
