import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'status_layout.dart';

/// Shared compose path for preview-scale math and full-res export (T2.28).
class StatusCompositor {
  StatusCompositor({BaseCacheManager? cache})
      : _cache = cache ?? DefaultCacheManager();

  final BaseCacheManager _cache;

  Future<ui.Image> loadUrl(String url) async {
    final file = await _cache.getSingleFile(url);
    return decodeFile(file);
  }

  Future<ui.Image> decodeFile(File file) async {
    final bytes = await file.readAsBytes();
    return decodeBytes(bytes);
  }

  Future<ui.Image> decodeBytes(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  Future<ui.Image> compose({
    required ui.Image base,
    ui.Image? photo,
    required String name,
    required StatusMeta meta,
    String watermarkText = 'Dhamma Path',
  }) async {
    final srcW = base.width.toDouble();
    final srcH = base.height.toDouble();
    final scale = srcW < 1080 ? 1080 / srcW : 1.0;
    final outW = (srcW * scale).round();
    final outH = (srcH * scale).round();

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.scale(scale);
    canvas.drawImage(base, Offset.zero, Paint());

    final canvasSize = Size(srcW, srcH);
    if (photo != null) {
      final rect = statusPhotoRect(meta.photoFrame, canvasSize);
      canvas.save();
      canvas.clipPath(Path()..addOval(rect));
      paintImage(
        canvas: canvas,
        rect: rect,
        image: photo,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
      );
      canvas.restore();
      canvas.drawOval(
        rect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = rect.width * 0.04
          ..color = Colors.white,
      );
    }

    if (name.trim().isNotEmpty) {
      final style = meta.nameText;
      final painter = TextPainter(
        text: TextSpan(
          text: name,
          style: TextStyle(
            color: colorFromHex(style.color),
            fontSize: statusNameFontSize(style, canvasSize),
            fontWeight: fontWeightFrom(style.weight),
            shadows: const [
              Shadow(color: Color(0xCC000000), blurRadius: 8, offset: Offset(0, 1)),
              Shadow(color: Color(0xCC000000), blurRadius: 2),
            ],
          ),
        ),
        textAlign: textAlignFrom(style.align),
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '…',
      );
      final maxW = style.w * srcW;
      painter.layout(maxWidth: maxW <= 0 ? srcW : maxW);
      var dx = style.x * srcW;
      if (style.align == 'center') {
        dx -= painter.width / 2;
      } else if (style.align == 'right') {
        dx -= painter.width;
      }
      painter.paint(canvas, Offset(dx, style.y * srcH));
    }

    if (meta.watermark && watermarkText.isNotEmpty) {
      final mark = TextPainter(
        text: TextSpan(
          text: watermarkText,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: srcH * 0.028,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      mark.paint(
        canvas,
        Offset(srcW - mark.width - srcW * 0.03, srcH - mark.height - srcH * 0.02),
      );
    }

    final picture = recorder.endRecording();
    return picture.toImage(outW, outH);
  }

  Future<Uint8List> composePng({
    required String baseUrl,
    File? photoFile,
    required String name,
    required StatusMeta meta,
  }) async {
    final base = await loadUrl(baseUrl);
    ui.Image? photo;
    if (photoFile != null && await photoFile.exists()) {
      photo = await decodeFile(photoFile);
    }
    final image = await compose(
      base: base,
      photo: photo,
      name: name,
      meta: meta,
    );
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw StateError('Could not encode status PNG.');
    }
    return byteData.buffer.asUint8List();
  }
}
