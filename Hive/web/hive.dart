import 'dart:html';
import 'dart:math' show Random;

import '../lib/rect.dart';

Map assets = {};

void main() {
  var assetNames = [ 'ant', 'beetle', 'grasshopper', 'queen', 'spider' ];
  for (var assetName in assetNames) {
    var image = new ImageElement(src: 'images/${assetName}.png');
    image.onLoad.listen((value) => render());
    assets[assetName] = image;
  }
}

void render() {
  CanvasElement canvas = querySelector("#hive_canvas_id");
  canvas.width = 500;
  canvas.height = 500;
  
  var context = canvas.context2D;
  for (var row = 0; row < 5; row++) {
    for (var col = 0; col < 5; col++) {
      var tile = new Tile(row, col);
      tile.draw(context);
    }
  }
}

class Tile {
  static final num width = 80;
  static final num height = 90;
  
  static final num pointHeight = .25;
  
  static Random random;
  
  num row, col;
  
  Tile(this.row, this.col) {
    random = new Random();
  }

  void draw(CanvasRenderingContext2D context) {
    var xOffset = this.col * width;
    if (this.row % 2 == 1) { xOffset += .5 * width; }
    
    var yOffset = this.row * height * .75;
    
    // stroke borders intersect canvas bounds
    xOffset += 1;
    yOffset += 1;

    var isWhite = random.nextBool();
    
    context.fillStyle = isWhite ? '#fff' : '#888';
    context.strokeStyle = '#333';
    context.beginPath();
    context.moveTo(xOffset, yOffset + pointHeight * height);
    context.lineTo(xOffset + .5 * width, yOffset);
    context.lineTo(xOffset + width, yOffset + pointHeight * height);
    context.lineTo(xOffset + width, yOffset + (1 - pointHeight) * height);
    context.lineTo(xOffset + 0.5 * width, yOffset + height);
    context.lineTo(xOffset, yOffset + (1 - pointHeight) * height);
    context.closePath();
    context.fill();
    context.stroke();
    
    var imageRectHeight = height * (1 - 2 * pointHeight);
    var imageRect = new Rectangle(xOffset, yOffset + pointHeight * height, width, imageRectHeight);
       
    var keys = assets.keys.toList();
    int keyIndex = random.nextInt(keys.length);
    var key = keys[keyIndex];
    ImageElement asset = assets[key];

    Rectangle scaledImageRect = aspectFill(imageRect, new Rectangle(0, 0, asset.width, asset.height));
//    context.strokeStyle = '#0f0';
//    context.strokeRect(imageRect.left, imageRect.top, imageRect.width, imageRect.height);
//    context.strokeStyle = '#00f';
//    context.strokeRect(scaledImageRect.left, scaledImageRect.top, scaledImageRect.width, scaledImageRect.height);
    context.drawImageScaled(asset, scaledImageRect.left, scaledImageRect.top, scaledImageRect.width, scaledImageRect.height);
  }
}
