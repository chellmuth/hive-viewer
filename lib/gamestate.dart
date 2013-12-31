library gamestate;

import 'view.dart';
import 'gamemodel.dart';
import 'rules.dart';

class Coordinate {
  num row, col;
  Coordinate(this.row, this.col);
  
  Coordinate applyDirection(Direction direction) {
    switch(direction) {
      case Direction.UP_LEFT:
        return _evenRow ? new Coordinate(row - 1, col - 1) : new Coordinate(row - 1, col);
      case Direction.UP_RIGHT:
        return _evenRow ? new Coordinate(row - 1, col) : new Coordinate(row - 1, col + 1);
      case Direction.RIGHT:
        return new Coordinate(row, col + 1);
      case Direction.DOWN_RIGHT:
        return _evenRow ? new Coordinate(row + 1, col) : new Coordinate(row + 1, col + 1);
      case Direction.DOWN_LEFT:
        return _evenRow ? new Coordinate(row + 1, col - 1) : new Coordinate(row + 1, col);
      case Direction.LEFT:
        return new Coordinate(row, col - 1);
      case Direction.ABOVE:
        return new Coordinate(row, col);
    }
  }
  
  bool isAdjacent(Coordinate other) {
    for (var direction in Direction.all()) {
      if (direction == Direction.ABOVE) { continue; }
      
      if (applyDirection(direction) == other) { return true; }
    }
    return false;
  }
  
  Direction direction(Coordinate other) {
    for (var direction in Direction.all()) {
      if (applyDirection(direction) == other) {
        return direction;
      }
    }
    throw new Exception("Invalid coordinates");
  }

  bool operator ==(other) {
    if (other is !Coordinate) { return false; }
    return row == other.row && col == other.col;
  }

  int get hashCode {
    // This is crappy because of overflowing integers -> doubles in Dart.
    int result = 17;
    result = 37 * result + row.hashCode;
    result = 37 * result + col.hashCode;
    return result;
  }

  String toString() {
    return '(${row}, ${col})';
  }
  
  bool get _evenRow => row % 2 == 0;
}

class GameState {
  int _stepCount = 1;
  List<Tile> tiles = [];
  List<Move> moves = [];

  void initialize(List<GameEvent> events) {
    moves = _mapGameEvents(events); 
  }
  
  GameState copy() {
    GameState copy = new GameState();
    var movesCopy = [];
    movesCopy.addAll(moves);
    copy.moves = movesCopy;
    copy.step(_stepCount);
    return copy;
  }

  void appendMove(Move move) {
    moves.add(move);
  }

  void stepToEnd() {
    step(moves.length);
  }

  void step(num stepCount) {
    _stepCount = stepCount;
    tiles = [];

    if (stepCount < 1) { stepCount = 1; }

    var pieceLocations = new Map<Piece, Coordinate>();

    for (Move move in moves.take(stepCount)) {
      if (move.currentLocation == null) {
        tiles.add(new Tile(move.targetLocation.row, move.targetLocation.col, move.piece));
        pieceLocations[move.piece] = move.targetLocation;
        continue;
      }
  
      if (pieceLocations.containsKey(move.piece)) {
        Coordinate currentLocation = move.currentLocation;
        tiles.remove(new Tile(currentLocation.row, currentLocation.col, move.piece));
      }
      Coordinate targetLocation = move.targetLocation;
      pieceLocations[move.piece] = targetLocation;
      tiles.add(new Tile(targetLocation.row, targetLocation.col, move.piece));
    }
  }
  
  List<Move> _mapGameEvents(List<GameEvent> gameEvents) {
    var moves = new List<Move>();
    var pieceLocations = new Map<Piece, Coordinate>();

    for (GameEvent event in gameEvents) {
      if (event.direction == null && event.relativePiece == null) {
        pieceLocations[event.piece] = new Coordinate(0, 0);
        moves.add(new Move(event.piece, null, new Coordinate(0, 0)));
        continue;
      }

      Coordinate currentLocation = null;
      if (pieceLocations.containsKey(event.piece)) {
        currentLocation = pieceLocations[event.piece];
      }

      Coordinate relativeLocation = pieceLocations[event.relativePiece];
      if (relativeLocation == null) {
        throw new Exception("Can't find relative piece");
      }
      var targetLocation = relativeLocation.applyDirection(event.direction);
      pieceLocations[event.piece] = targetLocation;
      
      moves.add(new Move(event.piece, currentLocation, targetLocation));
    }

    return moves;
  }
  
  List<Tile> toList() {
    return tiles;
  }
}