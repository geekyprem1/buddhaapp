import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses headings, bullets, bold and links', () {
    const raw = '''
<h2>Privacy</h2>
<p>We keep <b>only</b> what is needed.</p>
<ul><li>Name</li><li>Phone</li></ul>
<p>Read the <a href="https://dhammapath.app">site</a>.</p>
''';
    final blocks = parseSimpleHtml(raw);
    expect(blocks, hasLength(5));
    expect(blocks[0].kind, HtmlBlockKind.heading);
    expect(blocks[0].inlines.single.text, 'Privacy');
    expect(blocks[1].inlines[1].bold, isTrue);
    expect(blocks[2].kind, HtmlBlockKind.bullet);
    expect(blocks[3].kind, HtmlBlockKind.bullet);
    expect(
      blocks[4].inlines.map((i) => i.href).whereType<String>().single,
      'https://dhammapath.app',
    );
  });

  test('plain text becomes a paragraph', () {
    final blocks = parseSimpleHtml('Hello Dhamma Path.');
    expect(blocks, hasLength(1));
    expect(blocks.single.kind, HtmlBlockKind.paragraph);
    expect(blocks.single.inlines.single.text, 'Hello Dhamma Path.');
  });
}
