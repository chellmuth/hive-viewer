library gamestate;

import 'view.dart';
import 'gamemodel.dart';

class Coordinate {
  num row, col;
  Coordinate(this.row, this.col);
  
  Coordinate applyDirection(Direction direction) {
    switch(direction) {
      case Direction.UP_LEFT:
        return this._evenRow ? new Coordinate(this.row - 1, this.col - 1) : new Coordinate(this.row - 1, this.col);
      case Direction.UP_RIGHT:
        return this._evenRow ? new Coordinate(this.row - 1, this.col) : new Coordinate(this.row - 1, this.col + 1);
      case Direction.RIGHT:
        return new Coordinate(this.row, this.col + 1);
      case Direction.DOWN_RIGHT:
        return this._evenRow ? new Coordinate(this.row + 1, this.col) : new Coordinate(this.row + 1, this.col + 1);
      case Direction.DOWN_LEFT:
        return this._evenRow ? new Coordinate(this.row + 1, this.col - 1) : new Coordinate(this.row + 1, this.col);
      case Direction.LEFT:
        return new Coordinate(this.row, this.col - 1);
      case Direction.ABOVE:
        return new Coordinate(this.row, this.col);
    }
  }
  
  bool get _evenRow => this.row % 2 == 0;
}

class GameState {
  var tiles = [];
  var pieceLocations = {};
  
  void processEvents(List<GameEvent> events) {
    for (GameEvent event in events) {
      if (event.direction == null && event.relativePiece == null) {
        this.tiles.add(new Tile(0, 0, event.piece));
        this.pieceLocations[event.piece] = new Coordinate(0, 0);
        continue;
      }
  
      Coordinate relativeLocation = this.pieceLocations[event.relativePiece];
      if (relativeLocation == null) {
        throw new Exception("Can't find relative piece");
      }
      var pieceLocation = relativeLocation.applyDirection(event.direction);
      this.pieceLocations[event.piece] = pieceLocation;
      this.tiles.add(new Tile(pieceLocation.row, pieceLocation.col, event.piece));
    }
  }

  List<Tile> toList() {
    return tiles;
  }
}