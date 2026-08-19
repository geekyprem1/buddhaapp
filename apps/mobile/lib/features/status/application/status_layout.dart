import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// Maps normalised 0–1 status layout rects onto a canvas (Architecture §9.4).
Rect statusPhotoRect(LayoutRect frame, Size canvas) {
  // w/h are both 0–1; using width×w and height×h on a portrait image
  // makes an oval. A photo frame is a circle, so take the smaller side.
  final width = frame.w * canvas.width;
  final height = frame.h * canvas.height;
  final side = width < height ? width : height;
  return Rect.fromLTWH(
    frame.x * canvas.width,
    frame.y * canvas.height,
    side,
    side,
  );
}

Rect statusNameRect(StatusTextStyle style, Size canvas) {
  final height = style.size * canvas.height * 1.4;
  return Rect.fromLTWH(
    style.x * canvas.width,
    style.y * canvas.height,
    style.w * canvas.width,
    height,
  );
}

double statusNameFontSize(StatusTextStyle style, Size canvas) {
  return style.size * canvas.height;
}

Color colorFromHex(String hex) {
  var value = hex.replaceAll('#', '');
  if (value.length == 6) value = 'FF$value';
  return Color(int.parse(value, radix: 16));
}

FontWeight fontWeightFrom(int weight) {
  if (weight >= 800) return FontWeight.w800;
  if (weight >= 700) return FontWeight.w700;
  if (weight >= 600) return FontWeight.w600;
  if (weight >= 500) return FontWeight.w500;
  return FontWeight.w400;
}

TextAlign textAlignFrom(String align) {
  switch (align) {
    case 'center':
      return TextAlign.center;
    case 'right':
      return TextAlign.right;
    default:
      return TextAlign.left;
  }
}

StatusMeta statusMetaOf(ContentItem item) => item.statusMeta ?? const StatusMeta();
