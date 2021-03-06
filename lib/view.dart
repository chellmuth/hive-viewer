library view;

import 'dart:html';
import 'dart:math' show PI, max;

import 'assets.dart';
import 'gamemodel.dart';
import 'gamestate.dart';
import 'color.dart';

part 'bench.dart';


abstract class HexView {
  static final num width = 80 * 2;
  static final num height = 90 * 2;

  static final num pointHeight = .25;

  static final num xStackOffset = 6;
  static final num yStackOffset = 10;

  int get row;
  int get col;
  int get stackHeight => 1;
  String get strokeColor => '#000';
  String get fillColor => '#fff';

  num get xOffset {
    var xOffset = col * width;
    if (row % 2 == 1) { xOffset += .5 * width; }

    xOffset += (stackHeight - 1) * xStackOffset;

    xOffset += 1;
    return xOffset;
  }

  num get yOffset {
    var yOffset = row * height * .75;
    yOffset -= (stackHeight - 1) * yStackOffset;

    yOffset += 1;
    return yOffset;
  }

  void draw(CanvasRenderingContext2D context) {
    context.save();
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
    context.restore();
  }
}

class MoveView extends HexView {
  Coordinate location;
  int stackHeight;
  MoveView(this.location, stackHeight) {
    this.stackHeight = max(1, stackHeight);
  }

  int get row => location.row;
  int get col => location.col;

  void draw(CanvasRenderingContext2D context) {
    context.save();

    ImageElement asset = AssetLibrary.imageNamed("move-tile");
    context.drawImageScaledFromSource(asset, 0, 0, asset.naturalWidth, asset.naturalHeight, xOffset - 6, yOffset - 4, asset.naturalWidth, asset.naturalHeight);

    context.restore();
  }
}

class TileView extends HexView {
  static final num dotRadius = 3;
  Tile tile;
  Iterable<CoveredPieceView> coveredPieceViews;

  TileView(this.tile, List<Piece> coveredPieces) {
    coveredPieceViews = coveredPieces.map((piece) => new CoveredPieceView(piece));
  }

  int get row => tile.row;
  int get col => tile.col;
  int get stackHeight => tile.height;

  void draw(CanvasRenderingContext2D context) {
    //super.draw(context);

    context.save();

    ImageElement asset = AssetLibrary.imageForPiece(tile.piece);
    context.drawImageScaledFromSource(asset, 0, 0, asset.naturalWidth, asset.naturalHeight, xOffset - 6, yOffset - 4, asset.naturalWidth, asset.naturalHeight);

    var boxSize = 20;
    var dotContainerRect = new Rectangle(xOffset + .85 * HexView.width - boxSize / 2, yOffset + .3 * HexView.height - boxSize / 2, boxSize, boxSize);

//    context.fillStyle = '#00f';
//    context.fillRect(dotContainerRect.left, dotContainerRect.top, dotContainerRect.width, dotContainerRect.height);

    if (tile.piece.bugCount == 1) {
      _renderOneDot(context, dotContainerRect);
    } else if (tile.piece.bugCount == 2) {
      _renderTwoDots(context, dotContainerRect);
    } else if (tile.piece.bugCount == 3) {
      _renderThreeDots(context, dotContainerRect);
    }

    var diameter = 30;
    var margin = 6;
    Rectangle coveredPieceBounds = new Rectangle(xOffset + 4, yOffset + HexView.height * (1 - HexView.pointHeight) - diameter - 4, diameter, diameter);
    for (CoveredPieceView coveredPieceView in coveredPieceViews) {
      coveredPieceView.draw(context, coveredPieceBounds);
      coveredPieceBounds = new Rectangle(coveredPieceBounds.left, coveredPieceBounds.top - diameter - margin, coveredPieceBounds.width, coveredPieceBounds.height);
    }

    context.restore();
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

    context.fillStyle = tile.piece.player == Player.WHITE ? Color.BlackTile : Color.WhiteTile;
    context.beginPath();
    context.arc(boundingRect.left + xCenter * boundingRect.width, boundingRect.top + yCenter * boundingRect.height, TileView.dotRadius, 0, PI * 2, true);
    context.closePath();
    context.fill();

    context.restore();
  }
}

class CoveredPieceView {
  Piece piece;

  CoveredPieceView(this.piece);

  String get letter {
    switch (piece.bug) {
      case Bug.ANT: return 'A';
      case Bug.BEETLE: return 'B';
      case Bug.GRASSHOPPER: return 'G';
      case Bug.QUEEN: return 'Q';
      case Bug.SPIDER: return 'S';
      case Bug.MOSQUITO: return 'M';
    }
  }

  String get color {
    switch (piece.bug) {
      case Bug.ANT: return '#6DA9EE';
      case Bug.BEETLE: return '#E56CFE';
      case Bug.GRASSHOPPER: return '#9ADA54';
      case Bug.QUEEN: return '#F8E71C';
      case Bug.SPIDER: return '#CA9668';
      case Bug.MOSQUITO: return '#C4C4C4';
    }
  }


  void draw(CanvasRenderingContext2D context, Rectangle bounds) {
    context.save();
    context.fillStyle = color;

    context.beginPath();
    context.arc(bounds.left + bounds.width / 2, bounds.top + bounds.height / 2, bounds.width / 2, 0, PI * 2, true);
    context.closePath();
    context.fill();

    var fontSize = 14;
    context.font = '${fontSize}pt Futura';
    context.fillStyle = piece.player == Player.WHITE ? Color.WhiteTile : Color.BlackTile;
    var metrics = context.measureText(letter);
    context.fillText(letter, bounds.left + bounds.width / 2 - metrics.width / 2, bounds.top + bounds.height / 2 + fontSize / 2);
    context.restore();
  }
}