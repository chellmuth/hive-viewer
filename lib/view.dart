library view;

import 'dart:html';
import 'dart:math' show PI;

import 'rect.dart';
import 'assets.dart';
import 'gamemodel.dart';

abstract class HexView {
  static final num width = 80;
  static final num height = 90;
  
  static final num pointHeight = .25;
  static final num dotRadius = 2;
  
  int get row;
  int get col;
  String get strokeColor;
  String get fillColor;
  
  num get xOffset {
    var xOffset = col * width;
    if (row % 2 == 1) { xOffset += .5 * width; }
    xOffset += 1;
    return xOffset;
  }

  num get yOffset {
    var yOffset = row * height * .75;
    yOffset += 1;
    return yOffset;
  }
  
  void draw(CanvasRenderingContext2D context) {
    context.fillStyle = fillColor;
    context.strokeStyle = strokeColor;
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
    
  }
}

class TileView extends HexView {
  Tile tile;
  
  TileView(this.tile);

  int get row => tile.row;
  int get col => tile.col;
  String get fillColor => tile.piece.player == Player.WHITE ? '#fff' : '#888';
  String get strokeColor => tile.highlight ? '#f00' : '#333';
  
  void draw(CanvasRenderingContext2D context) {
    super.draw(context);

    var imageRectHeight = HexView.height * (1 - 2 * HexView.pointHeight);
    var imageRect = new Rectangle(xOffset, yOffset + HexView.pointHeight * HexView.height, HexView.width, imageRectHeight);
       
    ImageElement asset = AssetLibrary.imageForBug(tile.piece.bug);
    Rectangle scaledImageRect = aspectFill(imageRect, new Rectangle(0, 0, asset.width, asset.height));
//    context.strokeStyle = '#0f0';
//    context.strokeRect(imageRect.left, imageRect.top, imageRect.width, imageRect.height);
//    context.strokeStyle = '#00f';
//    context.strokeRect(scaledImageRect.left, scaledImageRect.top, scaledImageRect.width, scaledImageRect.height);
    context.drawImageScaled(asset, scaledImageRect.left, scaledImageRect.top, scaledImageRect.width, scaledImageRect.height);

    var boxSize = 16;
    var dotContainerRect = new Rectangle(xOffset + .8 * HexView.width - boxSize / 2, yOffset + .3 * HexView.height - boxSize / 2, boxSize, boxSize);

//    context.fillStyle = '#00f';
//    context.fillRect(dotContainerRect.left, dotContainerRect.top, dotContainerRect.width, dotContainerRect.height);

    if (tile.piece.bugCount == 1) {
      _renderOneDot(context, dotContainerRect);
    } else if (tile.piece.bugCount == 2) {
      _renderTwoDots(context, dotContainerRect);
    } else if (tile.piece.bugCount == 3) {
      _renderThreeDots(context, dotContainerRect);
    }

  }
  void _renderOneDot(CanvasRenderingContext2D context, Rectangle boundingRect) {
    _renderDot(context, boundingRect, 1/2, 1/2);
  }

  void _renderTwoDots(CanvasRenderingContext2D context, Rectangle boundingRect) {
    _renderDot(context, boundingRect, 1/4, 1/2);
    _renderDot(context, boundingRect, 3/4, 1/2);
  }
  
  void _renderThreeDots(CanvasRenderingContext2D context, Rectangle boundingRect) {
    _renderDot(context, boundingRect, 1/4, 2/3);
    _renderDot(context, boundingRect, 3/4, 2/3);
    _renderDot(context, boundingRect, 1/2, 1/3);
}
  
  void _renderDot(CanvasRenderingContext2D context, Rectangle boundingRect, num xCenter, num yCenter) {
    context.save();

    context.fillStyle = fillColor;
    context.beginPath();
    context.arc(boundingRect.left + xCenter * boundingRect.width, boundingRect.top + yCenter * boundingRect.height, HexView.dotRadius, 0, PI * 2, true);
    context.closePath();
    context.fill();

    context.restore();
  }

}