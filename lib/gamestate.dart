library gamestate;

import 'view.dart';
import 'gamemodel.dart';

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
  
  bool get _evenRow => row % 2 == 0;
}

class GameState {
  int _stepCount = 1;
  List<Tile> tiles = [];
  Map<Piece, Coordinate> pieceLocations = {};

  List<GameEvent> events;

  void initialize(List<GameEvent> events) {
    this.events = events;
    tiles = [];
    pieceLocations = {};
  }
  
  GameState copy() {
    GameState copy = new GameState();
    var eventsCopy = [];
    eventsCopy.addAll(events);
    copy.initialize(eventsCopy);
    copy.step(_stepCount);
    return copy;
  }

  void appendGameEvent(GameEvent gameEvent) {
    events.add(gameEvent);
  }

  void step(num stepCount) {
    _stepCount = stepCount;

    if (stepCount < 1) { stepCount = 1; }
    tiles = [];
    pieceLocations = {};

    for (GameEvent event in events.take(stepCount)) {
      if (event.direction == null && event.relativePiece == null) {
        tiles.add(new Tile(0, 0, event.piece));
        pieceLocations[event.piece] = new Coordinate(0, 0);
        continue;
      }
  
      Coordinate relativeLocation = pieceLocations[event.relativePiece];
      if (relativeLocation == null) {
        throw new Exception("Can't find relative piece");
      }
      var pieceLocation = relativeLocation.applyDirection(event.direction);
      if (pieceLocations.containsKey(event.piece)) {
        Coordinate previousLocation = pieceLocations[event.piece];
        tiles.remove(new Tile(previousLocation.row, previousLocation.col, event.piece));
      }
      pieceLocations[event.piece] = pieceLocation;
      tiles.add(new Tile(pieceLocation.row, pieceLocation.col, event.piece));
    }
  }
  
  List<Tile> toList() {
    return tiles;
  }
}