library rules;

import 'gamemodel.dart';
import 'gamestate.dart';

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
  return true;
}

bool checkFreedomOfMovementRule(Move move, GameState gamestate) {
  return true;
}

bool checkConstantContactRule(Move move, GameState gamestate) {
  return true;
}