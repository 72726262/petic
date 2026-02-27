import 'dart:io';
import 'package:image/image.dart' as img;

void main() async {
  print("Loading image...");
  final inputBytes = await File('assets/images/app_logo.jpg').readAsBytes();
  final image = img.decodeImage(inputBytes);
  if (image == null) {
    print("Could not decode image.");
    exit(1);
  }

  print("Processing image...");
  int width = image.width;
  int height = image.height;
  
  // Make a new image with 4 channels
  final newImage = img.Image(width: width, height: height, numChannels: 4);

  // Background color is close to white
  const threshold = 230;

  int minX = width;
  int minY = height;
  int maxX = 0;
  int maxY = 0;

  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final pixel = image.getPixel(x, y);
      
      if (pixel.r >= threshold && pixel.g >= threshold && pixel.b >= threshold) {
        newImage.setPixelRgba(x, y, 255, 255, 255, 0); // Transparent
      } else {
        newImage.setPixelRgba(x, y, pixel.r, pixel.g, pixel.b, 255);
        if (x < minX) minX = x;
        if (x > maxX) maxX = x;
        if (y < minY) minY = y;
        if (y > maxY) maxY = y;
      }
    }
  }

  // Add 10% padding to bounds 
  if (minX <= maxX && minY <= maxY) {
      final w = maxX - minX + 1;
      final h = maxY - minY + 1;
      final padX = (w * 0.1).toInt();
      final padY = (h * 0.1).toInt();
      
      minX = (minX - padX).clamp(0, width - 1);
      minY = (minY - padY).clamp(0, height - 1);
      maxX = (maxX + padX).clamp(0, width - 1);
      maxY = (maxY + padY).clamp(0, height - 1);
      
      final cropW = maxX - minX + 1;
      final cropH = maxY - minY + 1;
      
      final cropped = img.copyCrop(newImage, x: minX, y: minY, width: cropW, height: cropH);
      await File('assets/images/app_logo_transparent.png').writeAsBytes(img.encodePng(cropped));
      print("Saved cropped transparent image -> app_logo_transparent.png (w:$cropW h:$cropH)");
  } else {
      await File('assets/images/app_logo_transparent.png').writeAsBytes(img.encodePng(newImage));
      print("Saved transparent image -> app_logo_transparent.png");
  }
}
