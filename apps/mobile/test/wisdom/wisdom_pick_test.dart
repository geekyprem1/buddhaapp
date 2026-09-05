import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dhamma_path/features/wisdom/application/wisdom_providers.dart';

Wisdom _card(String id) => Wisdom(
      id: id,
      title: LocalisedText(en: id),
      body: const LocalisedText(en: 'body'),
    );

void main() {
  final cards = [_card('a'), _card('b'), _card('c')];

  test('empty list yields null', () {
    expect(pickWisdomForDate(const [], DateTime(2026, 9, 5)), isNull);
  });

  test('same day always picks the same card', () {
    final first = pickWisdomForDate(cards, DateTime(2026, 9, 5, 8, 30));
    final second = pickWisdomForDate(cards, DateTime(2026, 9, 5, 23, 59));
    expect(first, isNotNull);
    expect(first!.id, second!.id);
  });

  test('consecutive days spread across cards, not upload order', () {
    final picks = {
      for (var d = 1; d <= 9; d++)
        pickWisdomForDate(cards, DateTime(2026, 9, d))!.id,
    };
    // All three cards appear within 9 days (a strict rotation would too,
    // but the hash must at least not stick to one card).
    expect(picks.length, greaterThan(1));
  });

  test('single card is always picked', () {
    expect(
      pickWisdomForDate([_card('only')], DateTime(2026, 1, 1))!.id,
      'only',
    );
  });
}
