library rules;

import 'gamemodel.dart';
import 'gamestate.dart';
import 'view.dart';

class Move {
  Piece piece;
  Coordinate currentLocation;
  Coordinate targetLocation;
  
  Move(this.piece, this.currentLocation, this.targetLocation);
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
    List<Tile> neighbors(Tile tile) {
      var neighbors = [];
      for (Tile possibleNeighbor in tiles) {
        if (tile.coordinate.isAdjacent(possibleNeighbor.coordinate)) {
          neighbors.add(possibleNeighbor);
        }
      }
      return neighbors;
    }

    checkedPieces.add(tile.piece);
    for (Tile neighbor in neighbors(tile)) {
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