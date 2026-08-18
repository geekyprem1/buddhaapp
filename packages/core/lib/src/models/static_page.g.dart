// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'static_page.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StaticPageImpl _$$StaticPageImplFromJson(Map json) => _$StaticPageImpl(
      slug: json['slug'] as String,
      title: LocalisedText.fromJson(
          Map<String, dynamic>.from(json['title'] as Map)),
      body: LocalisedText.fromJson(
          Map<String, dynamic>.from(json['body'] as Map)),
      updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
    );

Map<String, dynamic> _$$StaticPageImplToJson(_$StaticPageImpl instance) =>
    <String, dynamic>{
      'slug': instance.slug,
      'title': instance.title.toJson(),
      'body': instance.body.toJson(),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
    };
