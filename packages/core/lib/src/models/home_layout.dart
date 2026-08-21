/// `config/home_layout` — module order and visibility on Home (AR-7.1, FR-6.3).
abstract class HomeModuleIds {
  HomeModuleIds._();

  static const wallpaper = 'wallpaper';
  static const meditation = 'meditation';
  static const ringtone = 'ringtone';
  static const song = 'song';
  static const prarthana = 'prarthana';
  static const status = 'status';
  static const buddhistCalendar = 'buddhist_calendar';
  static const dailyPaliWord = 'daily_pali_word';
  static const chanting = 'chanting';
  static const tipitaka = 'tipitaka';
  static const dana = 'dana';
  static const buddhistPlaces = 'buddhist_places';

  static const all = <String>[
    wallpaper,
    meditation,
    ringtone,
    song,
    buddhistCalendar,
    dailyPaliWord,
    chanting,
    tipitaka,
    dana,
    buddhistPlaces,
    prarthana,
    status,
  ];

  static const wide = <String>{prarthana, status};

  static const comingSoon = <String>{
    dailyPaliWord,
    tipitaka,
    dana,
    buddhistPlaces,
  };

  static bool isKnown(String id) => all.contains(id);

  static bool isWide(String id) => wide.contains(id);

  static bool isComingSoon(String id) => comingSoon.contains(id);

  static String label(String id) => switch (id) {
        wallpaper => 'Wallpaper',
        meditation => 'Meditation',
        ringtone => 'Ringtone',
        song => 'Song',
        prarthana => 'Daily Prarthana',
        status => 'Trending Status',
        buddhistCalendar => 'Buddhist Calendar',
        dailyPaliWord => 'Daily Pali Word',
        chanting => 'Chanting',
        tipitaka => 'Tipitaka',
        dana => 'Dana',
        buddhistPlaces => 'Buddhist Places',
        _ => id,
      };
}

class HomeModule {
  const HomeModule({required this.id, this.visible = true});

  final String id;
  final bool visible;

  HomeModule copyWith({String? id, bool? visible}) {
    return HomeModule(id: id ?? this.id, visible: visible ?? this.visible);
  }

  factory HomeModule.fromJson(Map<String, dynamic> json) {
    return HomeModule(
      id: json['id'] as String? ?? '',
      visible: json['visible'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'visible': visible};
}

class HomeSection {
  const HomeSection._(this.ids, this.wide);

  factory HomeSection.grid(List<String> ids) => HomeSection._(ids, false);

  factory HomeSection.wide(String id) => HomeSection._([id], true);

  final List<String> ids;
  final bool wide;
}

class HomeLayout {
  const HomeLayout({this.modules = const []});

  final List<HomeModule> modules;

  static const defaults = HomeLayout(
    modules: [
      HomeModule(id: HomeModuleIds.wallpaper),
      HomeModule(id: HomeModuleIds.meditation),
      HomeModule(id: HomeModuleIds.ringtone),
      HomeModule(id: HomeModuleIds.song),
      HomeModule(id: HomeModuleIds.buddhistCalendar),
      HomeModule(id: HomeModuleIds.dailyPaliWord),
      HomeModule(id: HomeModuleIds.chanting),
      HomeModule(id: HomeModuleIds.tipitaka),
      HomeModule(id: HomeModuleIds.dana),
      HomeModule(id: HomeModuleIds.buddhistPlaces),
      HomeModule(id: HomeModuleIds.prarthana),
      HomeModule(id: HomeModuleIds.status),
    ],
  );

  /// Drops unknown/duplicate ids and appends any missing catalogue modules.
  HomeLayout normalize() {
    final seen = <String>{};
    final out = <HomeModule>[];
    for (final module in modules) {
      if (!HomeModuleIds.isKnown(module.id) || seen.contains(module.id)) {
        continue;
      }
      seen.add(module.id);
      out.add(module);
    }
    for (final id in HomeModuleIds.all) {
      if (seen.add(id)) {
        out.add(HomeModule(id: id));
      }
    }
    return HomeLayout(modules: out);
  }

  List<HomeModule> get visibleModules =>
      normalize().modules.where((m) => m.visible).toList();

  /// All regular modules stay in one continuous 2-column grid. Daily
  /// Prarthana and Trending Status are always rendered below it as wide cards.
  List<HomeSection> get sections {
    final visible = visibleModules;
    final gridIds = visible
        .where((module) => !HomeModuleIds.isWide(module.id))
        .map((module) => module.id)
        .toList();
    final wideIds = visible
        .where((module) => HomeModuleIds.isWide(module.id))
        .map((module) => module.id);

    return [
      if (gridIds.isNotEmpty) HomeSection.grid(gridIds),
      for (final id in wideIds) HomeSection.wide(id),
    ];
  }

  factory HomeLayout.fromJson(Map<String, dynamic> json) {
    final raw = json['modules'];
    if (raw is! List) return HomeLayout.defaults;
    return HomeLayout(
      modules: raw
          .whereType<Map>()
          .map((e) => HomeModule.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    ).normalize();
  }

  Map<String, dynamic> toJson() => {
        'modules': normalize().modules.map((m) => m.toJson()).toList(),
      };
}
