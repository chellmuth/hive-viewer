library gamestate;

import 'view.dart';
import 'gamemodel.dart';
import 'rules.dart';

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
  
  Coordinate locate(Piece piece) {
    var tile = tiles.firstWhere((tile) => tile.piece == piece);
    return tile.coordinate;
  }
  
  bool isLocationEmpty(Coordinate location) {
    return pieceAt(location) == null;
  }
  
  Piece pieceAt(Coordinate location) {
    var tile = tiles.firstWhere((tile) => tile.coordinate == location, orElse: () => null);
    if (tile == null) { return null; }
    return tile.piece;
  }
  
  List<Tile> neighbors(Coordinate location) {
    var neighbors = [];
    for (Tile possibleNeighbor in tiles) {
      if (location.isAdjacent(possibleNeighbor.coordinate)) {
        neighbors.add(possibleNeighbor);
      }
    }
    return neighbors;
  }
  
  List<Tile> toList() {
    return tiles;
  }
}