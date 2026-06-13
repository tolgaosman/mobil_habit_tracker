// One-off tool: generates logo assets from app_logo.png.
//
// 1) Android-12 splash icon (app_logo_splash.png): Android 12+ masks the splash
//    icon to a circle, so the logo must fit inside a 768px safe circle on a
//    1152x1152 canvas.
// 2) Adaptive launcher foreground (app_logo_foreground.png): the circular logo
//    scaled to fill the full 1080x1080 adaptive canvas so the launcher icon is
//    as large as the mask allows (used with inset 0 + a dark background).
//
// Run: dart run tool/gen_splash_icon.dart
import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  const src = 'assets/images/app_logo.png';

  final bytes = File(src).readAsBytesSync();
  final logo = img.decodePng(bytes);
  if (logo == null) {
    stderr.writeln('Could not decode $src');
    exit(1);
  }

  _composite(
    logo,
    out: 'assets/images/app_logo_splash.png',
    canvas: 1152,
    logoSize: 768,
  );

  // Foreground fills the whole canvas so the circular logo reaches the visible
  // edges of the masked adaptive icon (largest possible without distortion).
  _composite(
    logo,
    out: 'assets/images/app_logo_foreground.png',
    canvas: 1080,
    logoSize: 1080,
  );
}

void _composite(
  img.Image logo, {
  required String out,
  required int canvas,
  required int logoSize,
}) {
  final resized = img.copyResize(
    logo,
    width: logoSize,
    height: logoSize,
    interpolation: img.Interpolation.cubic,
  );

  final result = img.Image(width: canvas, height: canvas, numChannels: 4);
  img.fill(result, color: img.ColorRgba8(0, 0, 0, 0));

  final offset = (canvas - logoSize) ~/ 2;
  img.compositeImage(result, resized, dstX: offset, dstY: offset);

  File(out).writeAsBytesSync(img.encodePng(result));
  stdout.writeln('Wrote $out (${canvas}x$canvas, logo ${logoSize}px centered)');
}
