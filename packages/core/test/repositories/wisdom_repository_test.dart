import 'package:core/core.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeFirebaseFirestore firestore;

  setUp(() {
    firestore = FakeFirebaseFirestore();
  });

  group('WisdomRepository', () {
    test('create then watchAll returns rows in sort order', () async {
      final repo = WisdomRepository(firestore: firestore);
      await repo.create(
        const Wisdom(
          id: '',
          title: LocalisedText(en: 'Second'),
          body: LocalisedText(en: 'Body two'),
          sortOrder: 2,
        ),
      );
      await repo.create(
        const Wisdom(
          id: '',
          title: LocalisedText(en: 'First'),
          body: LocalisedText(en: 'Body one'),
          sortOrder: 1,
        ),
      );

      final all = await repo.watchAll().first;
      expect(all, hasLength(2));
      expect(all.first.title.en, 'First');
      expect(all.last.title.en, 'Second');
    });

    test('inactive cards are hidden from the active stream', () async {
      final repo = WisdomRepository(firestore: firestore);
      await repo.create(
        const Wisdom(
          id: '',
          title: LocalisedText(en: 'Hidden'),
          body: LocalisedText(en: 'Body'),
          isActive: false,
        ),
      );

      expect(await repo.getActiveWisdoms(), isEmpty);
    });

    test('createWithId then getById round-trips title, body and image',
        () async {
      final repo = WisdomRepository(firestore: firestore);
      await repo.createWithId(
        const Wisdom(
          id: 'morning_calm',
          title: LocalisedText(en: 'Calm', hi: 'शांत'),
          body: LocalisedText(en: 'Sit still.'),
          imageUrl: 'https://example.com/w.png',
        ),
      );

      final got = await repo.getById('morning_calm');
      expect(got, isNotNull);
      expect(got!.title.resolve('hi'), 'शांत');
      expect(got.body.en, 'Sit still.');
      expect(got.imageUrl, 'https://example.com/w.png');

      await repo.update(got.copyWith(sortOrder: 7));
      expect((await repo.getById('morning_calm'))!.sortOrder, 7);

      await repo.delete('morning_calm');
      expect(await repo.getById('morning_calm'), isNull);
    });
  });
}
