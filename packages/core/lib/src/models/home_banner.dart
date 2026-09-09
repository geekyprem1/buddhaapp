/// `homeBanners/{bannerId}` — an admin-managed promotional slide shown in the
/// Home carousel alongside the Today's Wisdom card.
///
/// Kept as a plain class (no freezed) to match [HomeModule] — the shape is
/// tiny and only ever (de)serialised here.
///
/// [moduleId] is one of [HomeModuleIds]; tapping the slide opens that module's
/// screen (reusing the same routing the home grid uses). An empty/unknown
/// [moduleId] means the slide is decorative and does nothing on tap.
class HomeBanner {
  const HomeBanner({
    required this.id,
    this.imageUrl,
    this.moduleId = '',
    this.sortOrder = 0,
    this.isActive = true,
  });

  final String id;
  final String? imageUrl;
  final String moduleId;
  final int sortOrder;
  final bool isActive;

  HomeBanner copyWith({
    String? id,
    String? imageUrl,
    String? moduleId,
    int? sortOrder,
    bool? isActive,
  }) {
    return HomeBanner(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      moduleId: moduleId ?? this.moduleId,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
    );
  }

  factory HomeBanner.fromJson(Map<String, dynamic> json) {
    return HomeBanner(
      id: json['id'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      moduleId: json['moduleId'] as String? ?? '',
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'imageUrl': imageUrl,
        'moduleId': moduleId,
        'sortOrder': sortOrder,
        'isActive': isActive,
      };
}
