import 'dart:io';
import 'package:image/image.dart' as img;

void main() async {
  final inputBytes = await File(r'C:\Users\HP\.gemini\antigravity\brain\db59c88e-18c8-4d6e-ae5a-01d7fbca3b9e\media__1772210507674.jpg').readAsBytes();
  var originalImage = img.decodeImage(inputBytes);
  if (originalImage == null) return;

  int w = originalImage.width;
  int h = originalImage.height;
  
  // The checkerboard is grayscale. The logo has color.
  // We will find the bounding box of colored pixels (saturation > threshold)
  // or pixels that define the glossy rounded square.
  // Glossy square might have shadows.
  // Let's print out the color difference (max(r,g,b) - min(r,g,b)) across the middle row
  // to find the left and right edges.
  
  int midY = h ~/ 2;
  int leftEdge = 0;
  int rightEdge = w - 1;
  
  // To find the actual square, let's look for the first pixel from left 
  // that is significantly different from the top-left background pixel.
  final bgPixel = originalImage.getPixel(0, 0);
  final bgR = bgPixel.r;
  final bgG = bgPixel.g;
  final bgB = bgPixel.b;
  
  bool isBg(img.Pixel p) {
    // Checkerboard cells are either like (255,255,255) or (204,204,204).
    // Let's check if pixel is very close to grayscale (diff <= 15)
    int maxV = [p.r, p.g, p.b].reduce((a, b) => a > b ? a : b).toInt();
    int minV = [p.r, p.g, p.b].reduce((a, b) => a < b ? a : b).toInt();
    return (maxV - minV) < 20; 
  }

  // Find left edge
  for (int x = 0; x < w ~/ 2; x++) {
    // Check a vertical strip
    int bgCount = 0;
    for (int y = h ~/ 4; y < 3 * h ~/ 4; y++) {
      if (isBg(originalImage.getPixel(x, y))) bgCount++;
    }
    if (bgCount < (h ~/ 2) * 0.9) { // If less than 90% is background
      leftEdge = x;
      break;
    }
  }
  
  // Find right edge
  for (int x = w - 1; x > w ~/ 2; x--) {
    int bgCount = 0;
    for (int y = h ~/ 4; y < 3 * h ~/ 4; y++) {
      if (isBg(originalImage.getPixel(x, y))) bgCount++;
    }
    if (bgCount < (h ~/ 2) * 0.9) {
      rightEdge = x;
      break;
    }
  }
  
  // Find top edge
  int topEdge = 0;
  for (int y = 0; y < h ~/ 2; y++) {
    int bgCount = 0;
    for (int x = w ~/ 4; x < 3 * w ~/ 4; x++) {
      if (isBg(originalImage.getPixel(x, y))) bgCount++;
    }
    if (bgCount < (w ~/ 2) * 0.9) {
      topEdge = y;
      break;
    }
  }

  // Find bottom edge
  int bottomEdge = h - 1;
  for (int y = h - 1; y > h ~/ 2; y--) {
    int bgCount = 0;
    for (int x = w ~/ 4; x < 3 * w ~/ 4; x++) {
      if (isBg(originalImage.getPixel(x, y))) bgCount++;
    }
    if (bgCount < (w ~/ 2) * 0.9) {
      bottomEdge = y;
      break;
    }
  }

  print("Detected logo bounds: left=$leftEdge, right=$rightEdge, top=$topEdge, bottom=$bottomEdge");
  
  // Let's add a small inset to be safe from anti-aliased borders 
  int inset = (rightEdge - leftEdge) ~/ 40; // 2.5% inset
  leftEdge += inset;
  rightEdge -= inset;
  topEdge += inset;
  bottomEdge -= inset;
  
  int cropW = rightEdge - leftEdge + 1;
  int cropH = bottomEdge - topEdge + 1;
  
  print("Final crop bounds: W=$cropW, H=$cropH, X=$leftEdge, Y=$topEdge");
  
  if (cropW > 0 && cropH > 0) {
    var cropped = img.copyCrop(originalImage, x: leftEdge, y: topEdge, width: cropW, height: cropH);
    // Since it's a rounded square, let's also apply a circular/rounded mask
    // We will make the outside of the rounded rectangle transparent
    var finalImage = img.Image(width: cropW, height: cropH, numChannels: 4);
    
    // Corner radius approx 20% of width
    double r = cropW * 0.22;
    
    for (int y = 0; y < cropH; y++) {
      for (int x = 0; x < cropW; x++) {
        var p = cropped.getPixel(x, y);
        
        // Calculate distance from corners
        bool transparent = false;
        
        // Top-Left
        if (x < r && y < r) {
          if ((x - r) * (x - r) + (y - r) * (y - r) > r * r) transparent = true;
        }
        // Top-Right
        else if (x > cropW - r && y < r) {
          if ((x - (cropW - r)) * (x - (cropW - r)) + (y - r) * (y - r) > r * r) transparent = true;
        }
        // Bottom-Left
        else if (x < r && y > cropH - r) {
          if ((x - r) * (x - r) + (y - (cropH - r)) * (y - (cropH - r)) > r * r) transparent = true;
        }
        // Bottom-Right
        else if (x > cropW - r && y > cropH - r) {
          if ((x - (cropW - r)) * (x - (cropW - r)) + (y - (cropH - r)) * (y - (cropH - r)) > r * r) transparent = true;
        }
        
        if (transparent) {
          finalImage.setPixelRgba(x, y, 0, 0, 0, 0);
        } else {
          finalImage.setPixelRgba(x, y, p.r, p.g, p.b, 255);
        }
      }
    }
    
    await File('assets/images/app_logo_final.png').writeAsBytes(img.encodePng(finalImage));
    print("Saved carefully isolated logo to app_logo_final.png");
  }
}
