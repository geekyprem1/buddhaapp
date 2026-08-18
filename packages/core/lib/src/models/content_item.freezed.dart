// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'content_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ContentItem _$ContentItemFromJson(Map<String, dynamic> json) {
  return _ContentItem.fromJson(json);
}

/// @nodoc
mixin _$ContentItem {
  String get id => throw _privateConstructorUsedError;

  /// wallpaper | ringtone | song | meditation | status | prarthana
  String get type => throw _privateConstructorUsedError;
  List<String> get teacherIds => throw _privateConstructorUsedError;
  String? get categoryId => throw _privateConstructorUsedError;
  LocalisedText get title => throw _privateConstructorUsedError;

  /// Artist / narrator display name. Defaults to "Anonymous" in the UI
  /// layer, not stored here, so admin can distinguish "unset" from
  /// "explicitly anonymous".
  String? get artist => throw _privateConstructorUsedError;
  String? get mediaUrl => throw _privateConstructorUsedError;
  String? get thumbUrl => throw _privateConstructorUsedError;
  String? get storagePath => throw _privateConstructorUsedError;

  /// `null` = language-agnostic (images). Set for audio items.
  String? get language => throw _privateConstructorUsedError;

  /// draft | published | unpublished | archived
  String get status => throw _privateConstructorUsedError;
  int get sortOrder => throw _privateConstructorUsedError;
  bool get isFeatured => throw _privateConstructorUsedError;
  bool get isPremium => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  ContentCounters get counters => throw _privateConstructorUsedError;

  /// Licence provenance — mandatory per PRD §8 / Q8. e.g. "own-artwork",
  /// "licensed-stock", "public-domain".
  String? get source => throw _privateConstructorUsedError;
  String? get licence => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get publishAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get expireAt => throw _privateConstructorUsedError;
  String? get createdBy => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get deletedAt =>
      throw _privateConstructorUsedError; // Type-specific payloads (see content_type_metas.dart).
// Stored under `statusMeta` in Firestore — NOT `status`, which is
// reserved for the draft/published workflow field above.
  WallpaperMeta? get wallpaper => throw _privateConstructorUsedError;
  AudioMeta? get audio => throw _privateConstructorUsedError;
  StatusMeta? get statusMeta => throw _privateConstructorUsedError;

  /// Serializes this ContentItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ContentItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ContentItemCopyWith<ContentItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ContentItemCopyWith<$Res> {
  factory $ContentItemCopyWith(
          ContentItem value, $Res Function(ContentItem) then) =
      _$ContentItemCopyWithImpl<$Res, ContentItem>;
  @useResult
  $Res call(
      {String id,
      String type,
      List<String> teacherIds,
      String? categoryId,
      LocalisedText title,
      String? artist,
      String? mediaUrl,
      String? thumbUrl,
      String? storagePath,
      String? language,
      String status,
      int sortOrder,
      bool isFeatured,
      bool isPremium,
      List<String> tags,
      ContentCounters counters,
      String? source,
      String? licence,
      @TimestampConverter() DateTime? publishAt,
      @TimestampConverter() DateTime? expireAt,
      String? createdBy,
      @TimestampConverter() DateTime? createdAt,
      @TimestampConverter() DateTime? updatedAt,
      @TimestampConverter() DateTime? deletedAt,
      WallpaperMeta? wallpaper,
      AudioMeta? audio,
      StatusMeta? statusMeta});

  $LocalisedTextCopyWith<$Res> get title;
  $ContentCountersCopyWith<$Res> get counters;
  $WallpaperMetaCopyWith<$Res>? get wallpaper;
  $AudioMetaCopyWith<$Res>? get audio;
  $StatusMetaCopyWith<$Res>? get statusMeta;
}

/// @nodoc
class _$ContentItemCopyWithImpl<$Res, $Val extends ContentItem>
    implements $ContentItemCopyWith<$Res> {
  _$ContentItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ContentItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? teacherIds = null,
    Object? categoryId = freezed,
    Object? title = null,
    Object? artist = freezed,
    Object? mediaUrl = freezed,
    Object? thumbUrl = freezed,
    Object? storagePath = freezed,
    Object? language = freezed,
    Object? status = null,
    Object? sortOrder = null,
    Object? isFeatured = null,
    Object? isPremium = null,
    Object? tags = null,
    Object? counters = null,
    Object? source = freezed,
    Object? licence = freezed,
    Object? publishAt = freezed,
    Object? expireAt = freezed,
    Object? createdBy = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? deletedAt = freezed,
    Object? wallpaper = freezed,
    Object? audio = freezed,
    Object? statusMeta = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      teacherIds: null == teacherIds
          ? _value.teacherIds
          : teacherIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      categoryId: freezed == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String?,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as LocalisedText,
      artist: freezed == artist
          ? _value.artist
          : artist // ignore: cast_nullable_to_non_nullable
              as String?,
      mediaUrl: freezed == mediaUrl
          ? _value.mediaUrl
          : mediaUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      thumbUrl: freezed == thumbUrl
          ? _value.thumbUrl
          : thumbUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      storagePath: freezed == storagePath
          ? _value.storagePath
          : storagePath // ignore: cast_nullable_to_non_nullable
              as String?,
      language: freezed == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
      isFeatured: null == isFeatured
          ? _value.isFeatured
          : isFeatured // ignore: cast_nullable_to_non_nullable
              as bool,
      isPremium: null == isPremium
          ? _value.isPremium
          : isPremium // ignore: cast_nullable_to_non_nullable
              as bool,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      counters: null == counters
          ? _value.counters
          : counters // ignore: cast_nullable_to_non_nullable
              as ContentCounters,
      source: freezed == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as String?,
      licence: freezed == licence
          ? _value.licence
          : licence // ignore: cast_nullable_to_non_nullable
              as String?,
      publishAt: freezed == publishAt
          ? _value.publishAt
          : publishAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      expireAt: freezed == expireAt
          ? _value.expireAt
          : expireAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdBy: freezed == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      deletedAt: freezed == deletedAt
          ? _value.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      wallpaper: freezed == wallpaper
          ? _value.wallpaper
          : wallpaper // ignore: cast_nullable_to_non_nullable
              as WallpaperMeta?,
      audio: freezed == audio
          ? _value.audio
          : audio // ignore: cast_nullable_to_non_nullable
              as AudioMeta?,
      statusMeta: freezed == statusMeta
          ? _value.statusMeta
          : statusMeta // ignore: cast_nullable_to_non_nullable
              as StatusMeta?,
    ) as $Val);
  }

  /// Create a copy of ContentItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LocalisedTextCopyWith<$Res> get title {
    return $LocalisedTextCopyWith<$Res>(_value.title, (value) {
      return _then(_value.copyWith(title: value) as $Val);
    });
  }

  /// Create a copy of ContentItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ContentCountersCopyWith<$Res> get counters {
    return $ContentCountersCopyWith<$Res>(_value.counters, (value) {
      return _then(_value.copyWith(counters: value) as $Val);
    });
  }

  /// Create a copy of ContentItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WallpaperMetaCopyWith<$Res>? get wallpaper {
    if (_value.wallpaper == null) {
      return null;
    }

    return $WallpaperMetaCopyWith<$Res>(_value.wallpaper!, (value) {
      return _then(_value.copyWith(wallpaper: value) as $Val);
    });
  }

  /// Create a copy of ContentItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AudioMetaCopyWith<$Res>? get audio {
    if (_value.audio == null) {
      return null;
    }

    return $AudioMetaCopyWith<$Res>(_value.audio!, (value) {
      return _then(_value.copyWith(audio: value) as $Val);
    });
  }

  /// Create a copy of ContentItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $StatusMetaCopyWith<$Res>? get statusMeta {
    if (_value.statusMeta == null) {
      return null;
    }

    return $StatusMetaCopyWith<$Res>(_value.statusMeta!, (value) {
      return _then(_value.copyWith(statusMeta: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ContentItemImplCopyWith<$Res>
    implements $ContentItemCopyWith<$Res> {
  factory _$$ContentItemImplCopyWith(
          _$ContentItemImpl value, $Res Function(_$ContentItemImpl) then) =
      __$$ContentItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String type,
      List<String> teacherIds,
      String? categoryId,
      LocalisedText title,
      String? artist,
      String? mediaUrl,
      String? thumbUrl,
      String? storagePath,
      String? language,
      String status,
      int sortOrder,
      bool isFeatured,
      bool isPremium,
      List<String> tags,
      ContentCounters counters,
      String? source,
      String? licence,
      @TimestampConverter() DateTime? publishAt,
      @TimestampConverter() DateTime? expireAt,
      String? createdBy,
      @TimestampConverter() DateTime? createdAt,
      @TimestampConverter() DateTime? updatedAt,
      @TimestampConverter() DateTime? deletedAt,
      WallpaperMeta? wallpaper,
      AudioMeta? audio,
      StatusMeta? statusMeta});

  @override
  $LocalisedTextCopyWith<$Res> get title;
  @override
  $ContentCountersCopyWith<$Res> get counters;
  @override
  $WallpaperMetaCopyWith<$Res>? get wallpaper;
  @override
  $AudioMetaCopyWith<$Res>? get audio;
  @override
  $StatusMetaCopyWith<$Res>? get statusMeta;
}

/// @nodoc
class __$$ContentItemImplCopyWithImpl<$Res>
    extends _$ContentItemCopyWithImpl<$Res, _$ContentItemImpl>
    implements _$$ContentItemImplCopyWith<$Res> {
  __$$ContentItemImplCopyWithImpl(
      _$ContentItemImpl _value, $Res Function(_$ContentItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of ContentItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? teacherIds = null,
    Object? categoryId = freezed,
    Object? title = null,
    Object? artist = freezed,
    Object? mediaUrl = freezed,
    Object? thumbUrl = freezed,
    Object? storagePath = freezed,
    Object? language = freezed,
    Object? status = null,
    Object? sortOrder = null,
    Object? isFeatured = null,
    Object? isPremium = null,
    Object? tags = null,
    Object? counters = null,
    Object? source = freezed,
    Object? licence = freezed,
    Object? publishAt = freezed,
    Object? expireAt = freezed,
    Object? createdBy = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? deletedAt = freezed,
    Object? wallpaper = freezed,
    Object? audio = freezed,
    Object? statusMeta = freezed,
  }) {
    return _then(_$ContentItemImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      teacherIds: null == teacherIds
          ? _value._teacherIds
          : teacherIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      categoryId: freezed == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String?,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as LocalisedText,
      artist: freezed == artist
          ? _value.artist
          : artist // ignore: cast_nullable_to_non_nullable
              as String?,
      mediaUrl: freezed == mediaUrl
          ? _value.mediaUrl
          : mediaUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      thumbUrl: freezed == thumbUrl
          ? _value.thumbUrl
          : thumbUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      storagePath: freezed == storagePath
          ? _value.storagePath
          : storagePath // ignore: cast_nullable_to_non_nullable
              as String?,
      language: freezed == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
      isFeatured: null == isFeatured
          ? _value.isFeatured
          : isFeatured // ignore: cast_nullable_to_non_nullable
              as bool,
      isPremium: null == isPremium
          ? _value.isPremium
          : isPremium // ignore: cast_nullable_to_non_nullable
              as bool,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      counters: null == counters
          ? _value.counters
          : counters // ignore: cast_nullable_to_non_nullable
              as ContentCounters,
      source: freezed == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as String?,
      licence: freezed == licence
          ? _value.licence
          : licence // ignore: cast_nullable_to_non_nullable
              as String?,
      publishAt: freezed == publishAt
          ? _value.publishAt
          : publishAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      expireAt: freezed == expireAt
          ? _value.expireAt
          : expireAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdBy: freezed == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      deletedAt: freezed == deletedAt
          ? _value.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      wallpaper: freezed == wallpaper
          ? _value.wallpaper
          : wallpaper // ignore: cast_nullable_to_non_nullable
              as WallpaperMeta?,
      audio: freezed == audio
          ? _value.audio
          : audio // ignore: cast_nullable_to_non_nullable
              as AudioMeta?,
      statusMeta: freezed == statusMeta
          ? _value.statusMeta
          : statusMeta // ignore: cast_nullable_to_non_nullable
              as StatusMeta?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ContentItemImpl implements _ContentItem {
  const _$ContentItemImpl(
      {required this.id,
      required this.type,
      final List<String> teacherIds = const <String>[],
      this.categoryId,
      required this.title,
      this.artist,
      this.mediaUrl,
      this.thumbUrl,
      this.storagePath,
      this.language,
      this.status = 'draft',
      this.sortOrder = 0,
      this.isFeatured = false,
      this.isPremium = false,
      final List<String> tags = const <String>[],
      this.counters = const ContentCounters(),
      this.source,
      this.licence,
      @TimestampConverter() this.publishAt,
      @TimestampConverter() this.expireAt,
      this.createdBy,
      @TimestampConverter() this.createdAt,
      @TimestampConverter() this.updatedAt,
      @TimestampConverter() this.deletedAt,
      this.wallpaper,
      this.audio,
      this.statusMeta})
      : _teacherIds = teacherIds,
        _tags = tags;

  factory _$ContentItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$ContentItemImplFromJson(json);

  @override
  final String id;

  /// wallpaper | ringtone | song | meditation | status | prarthana
  @override
  final String type;
  final List<String> _teacherIds;
  @override
  @JsonKey()
  List<String> get teacherIds {
    if (_teacherIds is EqualUnmodifiableListView) return _teacherIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_teacherIds);
  }

  @override
  final String? categoryId;
  @override
  final LocalisedText title;

  /// Artist / narrator display name. Defaults to "Anonymous" in the UI
  /// layer, not stored here, so admin can distinguish "unset" from
  /// "explicitly anonymous".
  @override
  final String? artist;
  @override
  final String? mediaUrl;
  @override
  final String? thumbUrl;
  @override
  final String? storagePath;

  /// `null` = language-agnostic (images). Set for audio items.
  @override
  final String? language;

  /// draft | published | unpublished | archived
  @override
  @JsonKey()
  final String status;
  @override
  @JsonKey()
  final int sortOrder;
  @override
  @JsonKey()
  final bool isFeatured;
  @override
  @JsonKey()
  final bool isPremium;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  @JsonKey()
  final ContentCounters counters;

  /// Licence provenance — mandatory per PRD §8 / Q8. e.g. "own-artwork",
  /// "licensed-stock", "public-domain".
  @override
  final String? source;
  @override
  final String? licence;
  @override
  @TimestampConverter()
  final DateTime? publishAt;
  @override
  @TimestampConverter()
  final DateTime? expireAt;
  @override
  final String? createdBy;
  @override
  @TimestampConverter()
  final DateTime? createdAt;
  @override
  @TimestampConverter()
  final DateTime? updatedAt;
  @override
  @TimestampConverter()
  final DateTime? deletedAt;
// Type-specific payloads (see content_type_metas.dart).
// Stored under `statusMeta` in Firestore — NOT `status`, which is
// reserved for the draft/published workflow field above.
  @override
  final WallpaperMeta? wallpaper;
  @override
  final AudioMeta? audio;
  @override
  final StatusMeta? statusMeta;

  @override
  String toString() {
    return 'ContentItem(id: $id, type: $type, teacherIds: $teacherIds, categoryId: $categoryId, title: $title, artist: $artist, mediaUrl: $mediaUrl, thumbUrl: $thumbUrl, storagePath: $storagePath, language: $language, status: $status, sortOrder: $sortOrder, isFeatured: $isFeatured, isPremium: $isPremium, tags: $tags, counters: $counters, source: $source, licence: $licence, publishAt: $publishAt, expireAt: $expireAt, createdBy: $createdBy, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, wallpaper: $wallpaper, audio: $audio, statusMeta: $statusMeta)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ContentItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality()
                .equals(other._teacherIds, _teacherIds) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.artist, artist) || other.artist == artist) &&
            (identical(other.mediaUrl, mediaUrl) ||
                other.mediaUrl == mediaUrl) &&
            (identical(other.thumbUrl, thumbUrl) ||
                other.thumbUrl == thumbUrl) &&
            (identical(other.storagePath, storagePath) ||
                other.storagePath == storagePath) &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            (identical(other.isFeatured, isFeatured) ||
                other.isFeatured == isFeatured) &&
            (identical(other.isPremium, isPremium) ||
                other.isPremium == isPremium) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.counters, counters) ||
                other.counters == counters) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.licence, licence) || other.licence == licence) &&
            (identical(other.publishAt, publishAt) ||
                other.publishAt == publishAt) &&
            (identical(other.expireAt, expireAt) ||
                other.expireAt == expireAt) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.wallpaper, wallpaper) ||
                other.wallpaper == wallpaper) &&
            (identical(other.audio, audio) || other.audio == audio) &&
            (identical(other.statusMeta, statusMeta) ||
                other.statusMeta == statusMeta));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        type,
        const DeepCollectionEquality().hash(_teacherIds),
        categoryId,
        title,
        artist,
        mediaUrl,
        thumbUrl,
        storagePath,
        language,
        status,
        sortOrder,
        isFeatured,
        isPremium,
        const DeepCollectionEquality().hash(_tags),
        counters,
        source,
        licence,
        publishAt,
        expireAt,
        createdBy,
        createdAt,
        updatedAt,
        deletedAt,
        wallpaper,
        audio,
        statusMeta
      ]);

  /// Create a copy of ContentItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ContentItemImplCopyWith<_$ContentItemImpl> get copyWith =>
      __$$ContentItemImplCopyWithImpl<_$ContentItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ContentItemImplToJson(
      this,
    );
  }
}

abstract class _ContentItem implements ContentItem {
  const factory _ContentItem(
      {required final String id,
      required final String type,
      final List<String> teacherIds,
      final String? categoryId,
      required final LocalisedText title,
      final String? artist,
      final String? mediaUrl,
      final String? thumbUrl,
      final String? storagePath,
      final String? language,
      final String status,
      final int sortOrder,
      final bool isFeatured,
      final bool isPremium,
      final List<String> tags,
      final ContentCounters counters,
      final String? source,
      final String? licence,
      @TimestampConverter() final DateTime? publishAt,
      @TimestampConverter() final DateTime? expireAt,
      final String? createdBy,
      @TimestampConverter() final DateTime? createdAt,
      @TimestampConverter() final DateTime? updatedAt,
      @TimestampConverter() final DateTime? deletedAt,
      final WallpaperMeta? wallpaper,
      final AudioMeta? audio,
      final StatusMeta? statusMeta}) = _$ContentItemImpl;

  factory _ContentItem.fromJson(Map<String, dynamic> json) =
      _$ContentItemImpl.fromJson;

  @override
  String get id;

  /// wallpaper | ringtone | song | meditation | status | prarthana
  @override
  String get type;
  @override
  List<String> get teacherIds;
  @override
  String? get categoryId;
  @override
  LocalisedText get title;

  /// Artist / narrator display name. Defaults to "Anonymous" in the UI
  /// layer, not stored here, so admin can distinguish "unset" from
  /// "explicitly anonymous".
  @override
  String? get artist;
  @override
  String? get mediaUrl;
  @override
  String? get thumbUrl;
  @override
  String? get storagePath;

  /// `null` = language-agnostic (images). Set for audio items.
  @override
  String? get language;

  /// draft | published | unpublished | archived
  @override
  String get status;
  @override
  int get sortOrder;
  @override
  bool get isFeatured;
  @override
  bool get isPremium;
  @override
  List<String> get tags;
  @override
  ContentCounters get counters;

  /// Licence provenance — mandatory per PRD §8 / Q8. e.g. "own-artwork",
  /// "licensed-stock", "public-domain".
  @override
  String? get source;
  @override
  String? get licence;
  @override
  @TimestampConverter()
  DateTime? get publishAt;
  @override
  @TimestampConverter()
  DateTime? get expireAt;
  @override
  String? get createdBy;
  @override
  @TimestampConverter()
  DateTime? get createdAt;
  @override
  @TimestampConverter()
  DateTime? get updatedAt;
  @override
  @TimestampConverter()
  DateTime?
      get deletedAt; // Type-specific payloads (see content_type_metas.dart).
// Stored under `statusMeta` in Firestore — NOT `status`, which is
// reserved for the draft/published workflow field above.
  @override
  WallpaperMeta? get wallpaper;
  @override
  AudioMeta? get audio;
  @override
  StatusMeta? get statusMeta;

  /// Create a copy of ContentItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ContentItemImplCopyWith<_$ContentItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
