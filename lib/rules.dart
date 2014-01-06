library rules;

import 'gamemodel.dart';
import 'gamestate.dart';

class Move {
  Piece piece;
  Coordinate currentLocation;
  Coordinate targetLocation;
  
  Move(this.piece, this.currentLocation, this.targetLocation);

  bool operator ==(other) {
    if (other is !Move) { return false; }
    return piece == other.piece && currentLocation == other.currentLocation && targetLocation == other.targetLocation; 
  }

  int get hashCode {
    return piece.hashCode ^ currentLocation.hashCode ^ targetLocation.hashCode;
  }
}

List<Move> validMoves(GameState gamestate) {
  return [];
}

bool checkOneHiveRule(Move move, GameState gamestate) {
  gamestate = gamestate.copy();
  gamestate.appendMove(move);
  gamestate.stepBy(1);
  
  var tiles = gamestate.toList();
  if (tiles.length == 1) { return true; }

  var checkedPieces = new Set<Piece>();
  
  void addNeighbors(Tile tile) {
    checkedPieces.add(tile.piece);
    for (Piece stackMate in gamestate.stackAt(tile.coordinate)) {
      checkedPieces.add(stackMate);
    }
    for (Tile neighbor in gamestate.neighbors(tile.coordinate)) {
      if (!checkedPieces.contains(neighbor.piece)) {
        checkedPieces.add(neighbor.piece);
        addNeighbors(neighbor);
      }
    }
  }

  addNeighbors(tiles.first);
  if (checkedPieces.length != tiles.length) { return false; }

  checkedPieces.clear();

  gamestate.removeTileForPiece(move.piece);
  addNeighbors(tiles.first);

  return checkedPieces.length == tiles.length;
}

bool checkFreedomOfMovementRule(Move move, GameState gamestate) {
  Direction moveDirection = move.currentLocation.direction(move.targetLocation);
  for (Direction adjacentDirection in moveDirection.adjacentDirections()) {
    Coordinate adjacentLocation = move.currentLocation.applyDirection(adjacentDirection);
    if (gamestate.isLocationEmpty(adjacentLocation)) { return true; }
  }
  return false;
}

// todo: this may be unnecessary if implemented implicitly in all move finders.
bool checkConstantContactRule(Move move, GameState gamestate) {
  Direction moveDirection = move.currentLocation.direction(move.targetLocation);
  for (Direction adjacentDirection in moveDirection.adjacentDirections()) {
    Coordinate adjacentLocation = move.currentLocation.applyDirection(adjacentDirection);
    if (!gamestate.isLocationEmpty(adjacentLocation)) { return true; }
  }
  return false;
}