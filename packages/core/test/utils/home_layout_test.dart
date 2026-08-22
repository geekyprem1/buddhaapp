import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HomeLayout', () {
    test('normalize appends missing catalogue modules', () {
      const raw = HomeLayout(
        modules: [HomeModule(id: HomeModuleIds.song, visible: false)],
      );
      final ids = raw.normalize().modules.map((m) => m.id).toList();
      expect(ids.first, HomeModuleIds.song);
      expect(ids, containsAll(HomeModuleIds.all));
      expect(ids.toSet(), hasLength(HomeModuleIds.all.length));
      expect(HomeModuleIds.isComingSoon(HomeModuleIds.chanting), isFalse);
    });

    test('sections keep all grid tiles above wide cards', () {
      const layout = HomeLayout(
        modules: [
          HomeModule(id: HomeModuleIds.wallpaper),
          HomeModule(id: HomeModuleIds.meditation),
          HomeModule(id: HomeModuleIds.prarthana),
          HomeModule(id: HomeModuleIds.ringtone),
          HomeModule(id: HomeModuleIds.status, visible: false),
          HomeModule(id: HomeModuleIds.song),
        ],
      );
      final sections = layout.sections;
      expect(sections, hasLength(2));
      expect(sections[0].wide, isFalse);
      expect(sections[0].ids, [
        HomeModuleIds.wallpaper,
        HomeModuleIds.meditation,
        HomeModuleIds.ringtone,
        HomeModuleIds.song,
        HomeModuleIds.vandana,
        HomeModuleIds.buddhistCalendar,
        HomeModuleIds.dailyPaliWord,
        HomeModuleIds.chanting,
        HomeModuleIds.tipitaka,
        HomeModuleIds.dana,
        HomeModuleIds.buddhistPlaces,
      ]);
      expect(sections[1].wide, isTrue);
      expect(sections[1].ids, [HomeModuleIds.prarthana]);
    });

    test('missing vandana slots in after song on a saved layout', () {
      const layout = HomeLayout(
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
      expect(
        layout.normalize().modules.map((m) => m.id).toList(),
        HomeModuleIds.all,
      );
    });

    test('hidden modules drop out of sections', () {
      final layout = HomeLayout(
        modules: [
          for (final id in HomeModuleIds.all)
            HomeModule(
              id: id,
              visible: id == HomeModuleIds.meditation,
            ),
        ],
      );
      expect(
          layout.visibleModules.map((m) => m.id), [HomeModuleIds.meditation]);
    });
  });
}
