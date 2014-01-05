library gamestate;

import 'gamemodel.dart';
import 'rules.dart';

class GameState {
  int _stepCount = 1;
  List<Tile> tiles = [];
  List<Move> moves = [];
  _PieceStacks pieceStacks;

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
    if (moves.length > 0) {
      moves = moves.getRange(0, _stepCount).toList();
    }
    moves.add(move);
  }

  void stepToEnd() {
    step(moves.length);
  }
  
  void stepBy(num stepBy) {
    step(_stepCount + stepBy);
  }

  void step(num stepCount) {
    if (stepCount < 1) { stepCount = 1; }
    if (stepCount > moves.length) { stepCount = moves.length; }

    _stepCount = stepCount;
    tiles = [];
    pieceStacks = new _PieceStacks();

    var pieceLocations = new Map<Piece, Coordinate>();

    for (Move move in moves.take(stepCount)) {
      if (move.currentLocation == null) {
        pieceStacks.pushPiece(move.piece, move.targetLocation);
        tiles.add(new Tile(move.targetLocation.row, move.targetLocation.col, move.piece, height: 1));
        pieceLocations[move.piece] = move.targetLocation;
        continue;
      }

      if (pieceLocations.containsKey(move.piece)) {
        Coordinate currentLocation = move.currentLocation;
        pieceStacks.popPiece(move.piece, currentLocation);
        tiles.remove(new Tile(currentLocation.row, currentLocation.col, move.piece));
      }
      Coordinate targetLocation = move.targetLocation;
      pieceLocations[move.piece] = targetLocation;
      pieceStacks.pushPiece(move.piece, move.targetLocation);
      var pieceHeight = pieceStacks.pieceHeight(move.piece, move.targetLocation);
      tiles.add(new Tile(targetLocation.row, targetLocation.col, move.piece, height: pieceHeight));
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
    List<Tile> tileStack = tiles.where((tile) => tile.coordinate == location)
        .toList();
    tileStack.sort((t1, t2) => t1.height.compareTo(t2.height));

    if (tileStack.isEmpty) { return null; }
    return tileStack.last.piece;
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
  
  num get percentComplete => _stepCount / moves.length;
}

class _PieceStacks {
  Map<Coordinate, List<Piece>> stacks = {};

  void pushPiece(Piece piece, Coordinate location) {
    if (stacks.containsKey(location)) {
      stacks[location].add(piece);
    } else {
      stacks[location] = [ piece ];
    }
  }

  void popPiece(Piece piece, Coordinate location) {
    stacks[location].removeLast();
  }

  int pieceHeight(Piece piece, Coordinate location) {
    return stacks[location].length;
  }
}