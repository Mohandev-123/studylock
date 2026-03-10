// ignore_for_file: depend_on_referenced_packages
import 'dart:io';
import 'dart:math';

import 'package:image/image.dart' as img;

void main() {
  const renderSize = 2048;
  const outputSize = 1024;

  final full = img.Image(width: renderSize, height: renderSize);
  _drawBackground(full);
  _drawLockSymbol(
    full,
    cx: renderSize / 2,
    cy: renderSize / 2 + 70,
    scale: 1.0,
    includePlate: true,
  );

  final fullOut = img.copyResize(
    full,
    width: outputSize,
    height: outputSize,
    interpolation: img.Interpolation.average,
  );

  final foreground = img.Image(width: renderSize, height: renderSize);
  _clear(foreground);
  _drawLockSymbol(
    foreground,
    cx: renderSize / 2,
    cy: renderSize / 2 + 40,
    scale: 1.05,
    includePlate: false,
  );

  final fgOut = img.copyResize(
    foreground,
    width: outputSize,
    height: outputSize,
    interpolation: img.Interpolation.average,
  );

  final outDir = Directory('assets/icon')..createSync(recursive: true);
  File('${outDir.path}/icon.png').writeAsBytesSync(img.encodePng(fullOut));
  File(
    '${outDir.path}/icon_foreground.png',
  ).writeAsBytesSync(img.encodePng(fgOut));

  stdout.writeln('Generated assets/icon/icon.png');
  stdout.writeln('Generated assets/icon/icon_foreground.png');
}

void _drawBackground(img.Image image) {
  final width = image.width;
  final height = image.height;
  final cx = width / 2;
  final cy = height / 2;
  final maxDist = sqrt(cx * cx + cy * cy);

  const topLeft = _Rgba(8, 14, 44, 255);
  const bottomRight = _Rgba(19, 76, 165, 255);
  const glowColor = _Rgba(56, 144, 255, 255);

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      final linearT = ((x + y) / (width + height)).clamp(0.0, 1.0);
      final base = _mix(topLeft, bottomRight, linearT);

      final dx = x - cx;
      final dy = y - cy;
      final radial = sqrt(dx * dx + dy * dy) / (width * 0.62);
      final glow = (1.0 - radial).clamp(0.0, 1.0);
      final glowBoost = pow(glow, 1.9) * 0.42;
      final glowMixed = _mix(base, glowColor, glowBoost);

      final cornerDist = sqrt(dx * dx + dy * dy) / maxDist;
      final vignette = pow(cornerDist, 1.7) * 0.55;
      final r = (glowMixed.r * (1.0 - vignette)).round().clamp(0, 255);
      final g = (glowMixed.g * (1.0 - vignette)).round().clamp(0, 255);
      final b = (glowMixed.b * (1.0 - vignette)).round().clamp(0, 255);

      image.setPixelRgba(x, y, r, g, b, 255);
    }
  }
}

void _drawLockSymbol(
  img.Image image, {
  required double cx,
  required double cy,
  required double scale,
  required bool includePlate,
}) {
  final plateW = (1290 * scale).round();
  final plateH = (1290 * scale).round();
  final plateR = (290 * scale).round();
  final plateX = (cx - plateW / 2).round();
  final plateY = (cy - plateH / 2).round();

  if (includePlate) {
    _fillRoundedRect(
      image,
      x: plateX + (12 * scale).round(),
      y: plateY + (32 * scale).round(),
      width: plateW,
      height: plateH,
      radius: plateR,
      top: const _Rgba(14, 34, 114, 90),
      bottom: const _Rgba(7, 20, 77, 90),
    );

    _fillRoundedRect(
      image,
      x: plateX,
      y: plateY,
      width: plateW,
      height: plateH,
      radius: plateR,
      top: const _Rgba(24, 54, 164, 255),
      bottom: const _Rgba(11, 26, 97, 255),
    );

    _fillRoundedRect(
      image,
      x: plateX + (42 * scale).round(),
      y: plateY + (40 * scale).round(),
      width: plateW - (84 * scale).round(),
      height: (190 * scale).round(),
      radius: (110 * scale).round(),
      top: const _Rgba(120, 180, 255, 58),
      bottom: const _Rgba(120, 180, 255, 0),
    );
  }

  final bodyW = (760 * scale).round();
  final bodyH = (660 * scale).round();
  final bodyR = (145 * scale).round();
  final bodyX = (cx - bodyW / 2).round();
  final bodyY = (cy + 120 * scale).round();

  final shackleOuter = 340.0 * scale;
  final shackleInner = 238.0 * scale;
  final shackleCy = bodyY + (20 * scale);
  final shackleTop = (shackleCy - shackleOuter).floor();
  final shackleBottom = (shackleCy + shackleOuter).ceil();
  final shackleLeft = (cx - shackleOuter).floor();
  final shackleRight = (cx + shackleOuter).ceil();

  for (int y = shackleTop; y <= shackleBottom; y++) {
    for (int x = shackleLeft; x <= shackleRight; x++) {
      final dx = x - cx;
      final dy = y - shackleCy;
      final dist = sqrt(dx * dx + dy * dy);
      if (dist > shackleOuter || dist < shackleInner || dy > 86 * scale) {
        continue;
      }

      final t = ((dy + shackleOuter) / (shackleOuter * 2)).clamp(0.0, 1.0);
      final color = _mix(
        const _Rgba(255, 255, 255, 255),
        const _Rgba(211, 228, 255, 255),
        t,
      );
      _blendPixel(image, x, y, color);
    }
  }

  final pillarW = (120 * scale).round();
  final pillarH = (140 * scale).round();
  final pillarR = (60 * scale).round();
  _fillRoundedRect(
    image,
    x: bodyX + (95 * scale).round(),
    y: bodyY - (24 * scale).round(),
    width: pillarW,
    height: pillarH,
    radius: pillarR,
    top: const _Rgba(240, 248, 255, 255),
    bottom: const _Rgba(220, 234, 255, 255),
  );
  _fillRoundedRect(
    image,
    x: bodyX + bodyW - (95 * scale).round() - pillarW,
    y: bodyY - (24 * scale).round(),
    width: pillarW,
    height: pillarH,
    radius: pillarR,
    top: const _Rgba(240, 248, 255, 255),
    bottom: const _Rgba(220, 234, 255, 255),
  );

  _fillRoundedRect(
    image,
    x: bodyX,
    y: bodyY,
    width: bodyW,
    height: bodyH,
    radius: bodyR,
    top: const _Rgba(255, 255, 255, 255),
    bottom: const _Rgba(221, 236, 255, 255),
  );

  _fillRoundedRect(
    image,
    x: bodyX + (28 * scale).round(),
    y: bodyY + (28 * scale).round(),
    width: bodyW - (56 * scale).round(),
    height: (150 * scale).round(),
    radius: (84 * scale).round(),
    top: const _Rgba(255, 255, 255, 74),
    bottom: const _Rgba(255, 255, 255, 0),
  );

  final keyCx = cx.round();
  final keyCy = bodyY + (285 * scale).round();
  final keyColor = const _Rgba(17, 44, 125, 255);
  _fillCircle(
    image,
    cx: keyCx,
    cy: keyCy,
    radius: (64 * scale).round(),
    color: keyColor,
  );
  _fillRoundedRect(
    image,
    x: keyCx - (26 * scale).round(),
    y: keyCy,
    width: (52 * scale).round(),
    height: (200 * scale).round(),
    radius: (26 * scale).round(),
    top: keyColor,
    bottom: keyColor,
  );
}

void _clear(img.Image image) {
  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      image.setPixelRgba(x, y, 0, 0, 0, 0);
    }
  }
}

void _fillCircle(
  img.Image image, {
  required int cx,
  required int cy,
  required int radius,
  required _Rgba color,
}) {
  final x0 = max(0, cx - radius);
  final x1 = min(image.width - 1, cx + radius);
  final y0 = max(0, cy - radius);
  final y1 = min(image.height - 1, cy + radius);
  final r2 = radius * radius;

  for (int y = y0; y <= y1; y++) {
    for (int x = x0; x <= x1; x++) {
      final dx = x - cx;
      final dy = y - cy;
      if (dx * dx + dy * dy <= r2) {
        _blendPixel(image, x, y, color);
      }
    }
  }
}

void _fillRoundedRect(
  img.Image image, {
  required int x,
  required int y,
  required int width,
  required int height,
  required int radius,
  required _Rgba top,
  required _Rgba bottom,
}) {
  final x0 = max(0, x);
  final y0 = max(0, y);
  final x1 = min(image.width - 1, x + width - 1);
  final y1 = min(image.height - 1, y + height - 1);

  for (int py = y0; py <= y1; py++) {
    final t = ((py - y) / max(1, height - 1)).clamp(0.0, 1.0);
    final color = _mix(top, bottom, t);

    for (int px = x0; px <= x1; px++) {
      if (_insideRoundedRect(px, py, x, y, width, height, radius)) {
        _blendPixel(image, px, py, color);
      }
    }
  }
}

bool _insideRoundedRect(
  int px,
  int py,
  int x,
  int y,
  int width,
  int height,
  int radius,
) {
  final left = x;
  final right = x + width - 1;
  final top = y;
  final bottom = y + height - 1;

  if (px >= left + radius && px <= right - radius) return true;
  if (py >= top + radius && py <= bottom - radius) return true;

  final tlx = left + radius;
  final tly = top + radius;
  final trx = right - radius;
  final try_ = top + radius;
  final blx = left + radius;
  final bly = bottom - radius;
  final brx = right - radius;
  final bry = bottom - radius;
  final r2 = radius * radius;

  final inTopLeft = (px - tlx) * (px - tlx) + (py - tly) * (py - tly) <= r2;
  final inTopRight = (px - trx) * (px - trx) + (py - try_) * (py - try_) <= r2;
  final inBottomLeft = (px - blx) * (px - blx) + (py - bly) * (py - bly) <= r2;
  final inBottomRight = (px - brx) * (px - brx) + (py - bry) * (py - bry) <= r2;

  return inTopLeft || inTopRight || inBottomLeft || inBottomRight;
}

void _blendPixel(img.Image image, int x, int y, _Rgba src) {
  if (x < 0 || x >= image.width || y < 0 || y >= image.height) return;
  final dst = image.getPixel(x, y);

  final srcA = src.a / 255.0;
  final dstA = dst.a / 255.0;
  final outA = srcA + dstA * (1.0 - srcA);

  if (outA <= 0.0) {
    image.setPixelRgba(x, y, 0, 0, 0, 0);
    return;
  }

  final outR = ((src.r * srcA + dst.r.toInt() * dstA * (1.0 - srcA)) / outA)
      .round();
  final outG = ((src.g * srcA + dst.g.toInt() * dstA * (1.0 - srcA)) / outA)
      .round();
  final outB = ((src.b * srcA + dst.b.toInt() * dstA * (1.0 - srcA)) / outA)
      .round();
  final outAlpha = (outA * 255.0).round().clamp(0, 255);

  image.setPixelRgba(
    x,
    y,
    outR.clamp(0, 255),
    outG.clamp(0, 255),
    outB.clamp(0, 255),
    outAlpha,
  );
}

_Rgba _mix(_Rgba a, _Rgba b, double t) {
  final ratio = t.clamp(0.0, 1.0);
  return _Rgba(
    _lerp(a.r, b.r, ratio),
    _lerp(a.g, b.g, ratio),
    _lerp(a.b, b.b, ratio),
    _lerp(a.a, b.a, ratio),
  );
}

int _lerp(int start, int end, double t) {
  return (start + (end - start) * t).round().clamp(0, 255);
}

class _Rgba {
  final int r;
  final int g;
  final int b;
  final int a;

  const _Rgba(this.r, this.g, this.b, this.a);
}
