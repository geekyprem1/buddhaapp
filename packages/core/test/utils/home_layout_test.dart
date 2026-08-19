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
    });

    test('sections keep consecutive grid tiles together', () {
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
      expect(sections, hasLength(3));
      expect(sections[0].wide, isFalse);
      expect(sections[0].ids, [HomeModuleIds.wallpaper, HomeModuleIds.meditation]);
      expect(sections[1].wide, isTrue);
      expect(sections[1].ids, [HomeModuleIds.prarthana]);
      expect(sections[2].ids, [HomeModuleIds.ringtone, HomeModuleIds.song]);
    });

    test('hidden modules drop out of sections', () {
      const layout = HomeLayout(
        modules: [
          HomeModule(id: HomeModuleIds.wallpaper, visible: false),
          HomeModule(id: HomeModuleIds.meditation),
          HomeModule(id: HomeModuleIds.ringtone, visible: false),
          HomeModule(id: HomeModuleIds.song, visible: false),
          HomeModule(id: HomeModuleIds.prarthana, visible: false),
          HomeModule(id: HomeModuleIds.status, visible: false),
        ],
      );
      expect(layout.visibleModules.map((m) => m.id), [HomeModuleIds.meditation]);
    });
  });
}
