library view;

import 'dart:html';
import 'dart:math' show Random, PI;

import 'rect.dart';
import 'assets.dart';

class Tile {
  static final num width = 80;
  static final num height = 90;
  
  static final num pointHeight = .25;
  
  static final num dotRadius = 2;

  static Random random;
  
  num row, col;
  bool isWhite;
  num dotCount;
  
  Tile(this.row, this.col) {
    random = new Random();
    this.isWhite = random.nextBool();
    this.dotCount = random.nextInt(3) + 1;
  }

  void draw(CanvasRenderingContext2D context) {
    var xOffset = this.col * width;
    if (this.row % 2 == 1) { xOffset += .5 * width; }
    
    var yOffset = this.row * height * .75;
    
    // stroke borders intersect canvas bounds
    xOffset += 1;
    yOffset += 1;
    
    context.fillStyle = this.isWhite ? '#fff' : '#888';
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
       
    var assets = AssetLibrary.assets;
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

    var boxSize = 16;
    var dotContainerRect = new Rectangle(xOffset + .8 * width - boxSize / 2, yOffset + .3 * height - boxSize / 2, boxSize, boxSize);

//    context.fillStyle = '#00f';
//    context.fillRect(dotContainerRect.left, dotContainerRect.top, dotContainerRect.width, dotContainerRect.height);

    if (this.dotCount == 1) {
      this._renderOneDot(context, dotContainerRect);
    } else if (this.dotCount == 2) {
      this._renderTwoDots(context, dotContainerRect);
    } else if (this.dotCount == 3) {
      this._renderThreeDots(context, dotContainerRect);
    }
  }
  
  void _renderOneDot(CanvasRenderingContext2D context, Rectangle boundingRect) {
    this._renderDot(context, boundingRect, 1/2, 1/2);
  }

  void _renderTwoDots(CanvasRenderingContext2D context, Rectangle boundingRect) {
    this._renderDot(context, boundingRect, 1/4, 1/2);
    this._renderDot(context, boundingRect, 3/4, 1/2);
  }
  
  void _renderThreeDots(CanvasRenderingContext2D context, Rectangle boundingRect) {
    this._renderDot(context, boundingRect, 1/4, 2/3);
    this._renderDot(context, boundingRect, 3/4, 2/3);
    this._renderDot(context, boundingRect, 1/2, 1/3);
}
  
  void _renderDot(CanvasRenderingContext2D context, Rectangle boundingRect, num xCenter, num yCenter) {
    context.save();

    context.fillStyle = this.isWhite ? '#888' : '#fff';
    context.beginPath();
    context.arc(boundingRect.left + xCenter * boundingRect.width, boundingRect.top + yCenter * boundingRect.height, dotRadius, 0, PI * 2, true);
    context.closePath();
    context.fill();

    context.restore();
  }
}