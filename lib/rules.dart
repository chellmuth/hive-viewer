library rules;

import 'gamemodel.dart';
import 'gamestate.dart';
import 'view.dart';

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
    // This is crappy because of overflowing integers -> doubles in Dart.
    int result = 17;
    result = 37 * result + piece.hashCode;
    result = 37 * result + currentLocation.hashCode;
    result = 37 * result + targetLocation.hashCode;
    return result;
  }
}

List<Move> validMoves(GameState gamestate) {
  return [];
}

List<Move> validMovesForPiece(Piece piece, GameState gamestate) {
  return [];
}

bool checkOneHiveRule(Move move, GameState gamestate) {
  gamestate = gamestate.copy();
  gamestate.appendMove(move);
  gamestate.stepToEnd();
  
  var tiles = gamestate.toList();
  if (tiles.length == 1) { return true; }

  var checkedPieces = new Set<Piece>();
  
  void addNeighbors(Tile tile) {
    checkedPieces.add(tile.piece);
    for (Tile neighbor in gamestate.neighbors(tile.piece)) {
      if (!checkedPieces.contains(neighbor.piece)) {
        checkedPieces.add(neighbor.piece);
        addNeighbors(neighbor);
      }
    }
  }

  addNeighbors(tiles.first);
  if (checkedPieces.length != tiles.length) { return false; }

  checkedPieces.clear();

  tiles.removeWhere((tile) => tile.piece == move.piece);
  addNeighbors(tiles.first);
  if (checkedPieces.length != tiles.length) { return false; }

  return true;

}

bool checkFreedomOfMovementRule(Move move, GameState gamestate) {
  return true;
}

bool checkConstantContactRule(Move move, GameState gamestate) {
  return true;
}