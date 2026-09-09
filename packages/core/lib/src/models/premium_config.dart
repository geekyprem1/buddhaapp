/// `config/premium` — admin-controlled settings for the premium paywall.
///
/// Currently just the promo video shown at the top of the premium page.
/// Kept as a plain class (no freezed) to match the other tiny config models.
class PremiumConfig {
  const PremiumConfig({this.videoUrl});

  /// Download URL of the admin-uploaded mp4 shown on the premium screen.
  final String? videoUrl;

  PremiumConfig copyWith({String? videoUrl}) {
    return PremiumConfig(videoUrl: videoUrl ?? this.videoUrl);
  }

  factory PremiumConfig.fromJson(Map<String, dynamic> json) {
    return PremiumConfig(videoUrl: json['videoUrl'] as String?);
  }

  Map<String, dynamic> toJson() => {'videoUrl': videoUrl};
}

/// The subscription that unlocks the premium modules.
///
/// The 3-day free trial and ₹199/month price are configured on the Play
/// Console base-plan/offer — the app only needs the product id.
abstract class PremiumProducts {
  PremiumProducts._();

  static const monthlySubscriptionId = 'dhamma_premium_monthly';
}

/// Home modules that require premium. Free modules (calendar, tipitaka,
/// places, daan, prarthana, status, wisdom, home slider) are not listed.
///
/// Values match [HomeModuleIds].
abstract class PremiumModules {
  PremiumModules._();

  static const ids = <String>{
    'wallpaper',
    'ringtone',
    'meditation',
    'song',
    'chanting',
    'vandana',
    'video',
    'status',
  };

  static bool isLocked(String moduleId) => ids.contains(moduleId);
}
