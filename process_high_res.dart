import 'dart:io';
import 'package:image/image.dart' as img;

void main() async {
  final inputBytes = await File(r'C:\Users\HP\.gemini\antigravity\brain\db59c88e-18c8-4d6e-ae5a-01d7fbca3b9e\media__1772210507674.jpg').readAsBytes();
  var originalImage = img.decodeImage(inputBytes);
  if (originalImage == null) return;

  int w = originalImage.width;
  int h = originalImage.height;
  print("Original size: ${w}x${h}");

  // We want to just preserve the image quality, but maybe the 
  // checkerboard can be removed by just taking the center square.
  // We'll save the untouched original to a new PNG first, and we can 
  // scale/crop it using Flutter's native UI so it retains 100% quality and anti-aliasing.
  
  // Actually, let's just copy the original as-is to assets/images/app_logo_high_res.jpg
  await File('assets/images/app_logo_high_res.jpg').writeAsBytes(inputBytes);
  print("Saved raw image to assets/images/app_logo_high_res.jpg");
}
