import 'package:dhamma_path_admin/util/slug.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('slugify makes a stable teacher id', () {
    expect(slugify('Gautam Buddha'), 'gautam_buddha');
    expect(slugify('  AnaPana  '), 'anapana');
    expect(slugify('Hello---World!!'), 'hello_world');
  });
}
