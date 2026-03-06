// ignore_for_file: depend_on_referenced_packages
import 'dart:io';
import 'dart:math';
import 'package:image/image.dart' as img;

/// Generates a 1024x1024 app icon for Study Lock.
/// Design: Dark blue gradient background with a white lock icon
/// and a small clock face at bottom-right of the lock.
void main() {
  const size = 1024;
  final image = img.Image(width: size, height: size);

  final cx = size / 2;
  final cy = size / 2;

  // ── 1. Background: dark-blue radial gradient ──────────────────────
  for (int y = 0; y < size; y++) {
    for (int x = 0; x < size; x++) {
      final dist = sqrt(pow(x - cx, 2) + pow(y - cy, 2)) / (size * 0.7);
      final t = dist.clamp(0.0, 1.0);
      final r = _lerp(0x0D, 0x06, t);
      final g = _lerp(0x19, 0x0A, t);
      final b = _lerp(0x4D, 0x1A, t);
      image.setPixelRgba(x, y, r, g, b, 255);
    }
  }

  // ── 2. Rounded rectangle background card (subtle) ─────────────────
  _fillRoundedRect(
    image,
    (cx - 280).round(),
    (cy - 300).round(),
    560,
    600,
    80,
    0x14,
    0x26,
    0x6B,
    120,
  );

  // ── 3. Lock body (rounded rectangle) ──────────────────────────────
  final lockBodyX = (cx - 170).round();
  final lockBodyY = (cy - 30).round();
  const lockBodyW = 340;
  const lockBodyH = 280;
  _fillRoundedRect(
    image,
    lockBodyX,
    lockBodyY,
    lockBodyW,
    lockBodyH,
    40,
    0xFF,
    0xFF,
    0xFF,
    255,
  );

  // ── 4. Lock shackle (arc - upper part) ────────────────────────────
  final shackleOuter = 150.0;
  final shackleInner = 110.0;
  final shackleCx = cx;
  final shackleCy = cy - 30.0;
  for (int y = 0; y < size; y++) {
    for (int x = 0; x < size; x++) {
      final dx = x - shackleCx;
      final dy = y - shackleCy;
      final dist = sqrt(dx * dx + dy * dy);
      if (dist >= shackleInner && dist <= shackleOuter && dy < 0) {
        image.setPixelRgba(x, y, 0xFF, 0xFF, 0xFF, 255);
      }
    }
  }

  // ── 5. Keyhole (circle + line) ────────────────────────────────────
  final keyCx = cx;
  final keyCy = cy + 70;
  _fillCircle(image, keyCx.round(), keyCy.round(), 30, 0x0D, 0x13, 0x33, 255);
  // Keyhole slot
  _fillRect(
    image,
    (keyCx - 10).round(),
    (keyCy + 20).round(),
    20,
    55,
    0x0D,
    0x13,
    0x33,
    255,
  );

  // ── 6. Clock face (bottom-right of lock) ──────────────────────────
  final clockCx = (cx + 140).round();
  final clockCy = (cy + 180).round();
  const clockR = 80;

  // Clock background circle (dark blue)
  _fillCircle(image, clockCx, clockCy, clockR + 10, 0x0D, 0x13, 0x33, 255);
  // Clock outline ring (blue)
  _drawCircleOutline(image, clockCx, clockCy, clockR, 8, 0x22, 0x44, 0xFF, 255);
  // Clock inner fill
  _fillCircle(image, clockCx, clockCy, clockR - 8, 0x0D, 0x13, 0x33, 255);

  // Clock hands
  // Hour hand (pointing to 10 o'clock)
  final hourAngle = -pi / 3; // 10 o'clock
  _drawLine(
    image,
    clockCx,
    clockCy,
    clockCx + (40 * cos(hourAngle)).round(),
    clockCy + (40 * sin(hourAngle)).round(),
    6,
    0x22,
    0x44,
    0xFF,
    255,
  );

  // Minute hand (pointing to 2 o'clock)
  final minAngle = pi / 6; // 2 o'clock
  _drawLine(
    image,
    clockCx,
    clockCy,
    clockCx + (55 * cos(minAngle)).round(),
    clockCy + (55 * sin(minAngle)).round(),
    5,
    0x22,
    0x44,
    0xFF,
    255,
  );

  // Clock center dot
  _fillCircle(image, clockCx, clockCy, 8, 0x22, 0x44, 0xFF, 255);

  // ── 7. Save ───────────────────────────────────────────────────────
  final outputDir = Directory('assets/icon');
  outputDir.createSync(recursive: true);

  final pngBytes = img.encodePng(image);
  File('assets/icon/icon.png').writeAsBytesSync(pngBytes);

  // Also create a foreground icon (for adaptive icons) — same but with
  // transparent background padding
  final fgImage = img.Image(width: size, height: size);
  // Fill transparent
  for (int y = 0; y < size; y++) {
    for (int x = 0; x < size; x++) {
      fgImage.setPixelRgba(x, y, 0, 0, 0, 0);
    }
  }

  // Copy the lock + clock part centered with some padding
  final padding = 108; // ~10% safe zone for adaptive
  for (int y = 0; y < size; y++) {
    for (int x = 0; x < size; x++) {
      final px = image.getPixel(x, y);
      // Only copy non-background pixels (the lock + clock)
      final r = px.r.toInt();
      final g = px.g.toInt();
      final b = px.b.toInt();
      // If pixel is clearly not the dark background
      if (r > 0x20 || g > 0x30 || b > 0x60) {
        final nx = x;
        final ny = y;
        if (nx >= 0 && nx < size && ny >= 0 && ny < size) {
          fgImage.setPixelRgba(nx, ny, r, g, b, 255);
        }
      }
    }
  }

  File(
    'assets/icon/icon_foreground.png',
  ).writeAsBytesSync(img.encodePng(fgImage));

  print('✓ Generated assets/icon/icon.png (1024x1024)');
  print('✓ Generated assets/icon/icon_foreground.png (1024x1024)');
}

int _lerp(int a, int b, double t) => (a + (b - a) * t).round().clamp(0, 255);

void _fillCircle(
  img.Image image,
  int cx,
  int cy,
  int radius,
  int r,
  int g,
  int b,
  int a,
) {
  for (int y = cy - radius; y <= cy + radius; y++) {
    for (int x = cx - radius; x <= cx + radius; x++) {
      if (x >= 0 && x < image.width && y >= 0 && y < image.height) {
        final dx = x - cx;
        final dy = y - cy;
        if (dx * dx + dy * dy <= radius * radius) {
          image.setPixelRgba(x, y, r, g, b, a);
        }
      }
    }
  }
}

void _drawCircleOutline(
  img.Image image,
  int cx,
  int cy,
  int radius,
  int thickness,
  int r,
  int g,
  int b,
  int a,
) {
  for (int y = cy - radius - thickness; y <= cy + radius + thickness; y++) {
    for (int x = cx - radius - thickness; x <= cx + radius + thickness; x++) {
      if (x >= 0 && x < image.width && y >= 0 && y < image.height) {
        final dx = x - cx;
        final dy = y - cy;
        final dist = sqrt(dx * dx + dy * dy);
        if (dist >= radius - thickness / 2 && dist <= radius + thickness / 2) {
          image.setPixelRgba(x, y, r, g, b, a);
        }
      }
    }
  }
}

void _fillRect(
  img.Image image,
  int x0,
  int y0,
  int w,
  int h,
  int r,
  int g,
  int b,
  int a,
) {
  for (int y = y0; y < y0 + h; y++) {
    for (int x = x0; x < x0 + w; x++) {
      if (x >= 0 && x < image.width && y >= 0 && y < image.height) {
        image.setPixelRgba(x, y, r, g, b, a);
      }
    }
  }
}

void _fillRoundedRect(
  img.Image image,
  int x0,
  int y0,
  int w,
  int h,
  int radius,
  int r,
  int g,
  int b,
  int a,
) {
  for (int y = y0; y < y0 + h; y++) {
    for (int x = x0; x < x0 + w; x++) {
      if (x >= 0 && x < image.width && y >= 0 && y < image.height) {
        // Check corners
        bool inside = true;
        if (x < x0 + radius && y < y0 + radius) {
          inside = _inCorner(x, y, x0 + radius, y0 + radius, radius);
        } else if (x > x0 + w - radius && y < y0 + radius) {
          inside = _inCorner(x, y, x0 + w - radius, y0 + radius, radius);
        } else if (x < x0 + radius && y > y0 + h - radius) {
          inside = _inCorner(x, y, x0 + radius, y0 + h - radius, radius);
        } else if (x > x0 + w - radius && y > y0 + h - radius) {
          inside = _inCorner(x, y, x0 + w - radius, y0 + h - radius, radius);
        }
        if (inside) {
          image.setPixelRgba(x, y, r, g, b, a);
        }
      }
    }
  }
}

bool _inCorner(int x, int y, int cx, int cy, int radius) {
  final dx = x - cx;
  final dy = y - cy;
  return dx * dx + dy * dy <= radius * radius;
}

void _drawLine(
  img.Image image,
  int x0,
  int y0,
  int x1,
  int y1,
  int thickness,
  int r,
  int g,
  int b,
  int a,
) {
  final dx = x1 - x0;
  final dy = y1 - y0;
  final steps = max(dx.abs(), dy.abs());
  if (steps == 0) return;
  for (int i = 0; i <= steps; i++) {
    final x = x0 + (dx * i / steps).round();
    final y = y0 + (dy * i / steps).round();
    _fillCircle(image, x, y, thickness ~/ 2, r, g, b, a);
  }
}
