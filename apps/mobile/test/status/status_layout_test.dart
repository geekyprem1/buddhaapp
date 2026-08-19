import 'package:core/core.dart';
import 'package:dhamma_path/features/status/application/status_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('photo frame maps 0–1 rects onto the canvas', () {
    const frame = LayoutRect(x: 0.62, y: 0.70, w: 0.22, h: 0.22);
    final rect = statusPhotoRect(frame, const Size(1000, 1000));
    expect(rect.left, closeTo(620, 0.001));
    expect(rect.top, closeTo(700, 0.001));
    expect(rect.width, closeTo(220, 0.001));
    expect(rect.height, closeTo(220, 0.001));
  });

  test('photo frame stays circular on a portrait canvas', () {
    const frame = LayoutRect(x: 0.62, y: 0.70, w: 0.22, h: 0.22);
    final rect = statusPhotoRect(frame, const Size(1080, 1350));
    expect(rect.width, closeTo(rect.height, 0.001));
    expect(rect.width, closeTo(0.22 * 1080, 0.001));
  });

  test('name font size is a fraction of canvas height', () {
    const style = StatusTextStyle(size: 0.045);
    expect(statusNameFontSize(style, const Size(1080, 1350)), closeTo(60.75, 0.01));
  });

  test('hex colours parse with and without hash', () {
    expect(colorFromHex('#1F1F1F'), const Color(0xFF1F1F1F));
    expect(colorFromHex('D4A24C'), const Color(0xFFD4A24C));
  });

  test('missing statusMeta falls back to defaults', () {
    const item = ContentItem(
      id: 'st_001',
      type: ContentType.status,
      title: LocalisedText(en: 'Dhyan'),
    );
    expect(statusMetaOf(item).photoFrame.w, 0.22);
  });
}
