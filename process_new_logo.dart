import 'dart:io';
import 'package:image/image.dart' as img;

void main() async {
  print("Loading new logo...");
  final inputBytes = await File(r'C:\Users\HP\.gemini\antigravity\brain\db59c88e-18c8-4d6e-ae5a-01d7fbca3b9e\media__1772210507674.jpg').readAsBytes();
  var originalImage = img.decodeImage(inputBytes);
  if (originalImage == null) {
    print("Could not decode image.");
    exit(1);
  }

  int width = originalImage.width;
  int height = originalImage.height;
  
  // Make a new image with 4 channels
  var image = img.Image(width: width, height: height, numChannels: 4);
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final p = originalImage.getPixel(x, y);
      image.setPixelRgba(x, y, p.r, p.g, p.b, 255);
    }
  }

  print("Flood filling background to transparent...");
  
  // Since the background might be a checkerboard of white and light gray, 
  // we'll consider any pixel with R, G, B > 200 as "background" for the edges.
  bool isBg(img.Pixel p) {
    // Check if it's white or light gray (the checkerboard pattern typically has high values)
    // Also, some checkerboards have white (255) and gray (204 or 192).
    // Let's be aggressive: anything grayscale-ish and bright above 180.
    int diffRG = (p.r - p.g).abs().toInt();
    int diffGB = (p.g - p.b).abs().toInt();
    int diffRB = (p.r - p.b).abs().toInt();
    bool isGrayscale = diffRG < 20 && diffGB < 20 && diffRB < 20;
    return isGrayscale && p.r > 170;
  }

  // Queue for flood fill
  final queue = <List<int>>[];
  
  void enqueueIfBg(int x, int y) {
    if (x >= 0 && x < width && y >= 0 && y < height) {
      final p = image.getPixel(x, y);
      if (p.a != 0 && isBg(p)) {
        image.setPixelRgba(x, y, 0, 0, 0, 0); // marked visited & transparent
        queue.add([x, y]);
      }
    }
  }

  // Start from corners
  enqueueIfBg(0, 0);
  enqueueIfBg(width - 1, 0);
  enqueueIfBg(0, height - 1);
  enqueueIfBg(width - 1, height - 1);

  int processed = 0;
  while (queue.isNotEmpty) {
    final pt = queue.removeLast();
    int x = pt[0];
    int y = pt[1];
    
    enqueueIfBg(x + 1, y);
    enqueueIfBg(x - 1, y);
    enqueueIfBg(x, y + 1);
    enqueueIfBg(x, y - 1);
    
    // Also diagonals to easily bleed through checkerboards
    enqueueIfBg(x + 1, y + 1);
    enqueueIfBg(x - 1, y - 1);
    enqueueIfBg(x + 1, y - 1);
    enqueueIfBg(x - 1, y + 1);
    
    processed++;
  }
  print("Flood fill converted $processed pixels to transparent.");

  // Also remove strict white pixels near the edges just in case
  // Find bounding box of non-transparent pixels
  int minX = width, minY = height, maxX = 0, maxY = 0;
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final p = image.getPixel(x, y);
      if (p.a > 0) {
        if (x < minX) minX = x;
        if (x > maxX) maxX = x;
        if (y < minY) minY = y;
        if (y > maxY) maxY = y;
      }
    }
  }

  print("Cropping image to bounding box...");
  if (minX <= maxX && minY <= maxY) {
      final cropW = maxX - minX + 1;
      final cropH = maxY - minY + 1;
      final cropped = img.copyCrop(image, x: minX, y: minY, width: cropW, height: cropH);
      await File('assets/images/app_logo_final.png').writeAsBytes(img.encodePng(cropped));
      print("Success! Saved as assets/images/app_logo_final.png");
  } else {
      await File('assets/images/app_logo_final.png').writeAsBytes(img.encodePng(image));
      print("Warning: Bounding box empty. Saved original as png.");
  }
}
