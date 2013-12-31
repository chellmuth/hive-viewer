library move_finder;

import 'gamemodel.dart';
import 'gamestate.dart';
import 'rules.dart';
import 'view.dart';

class JumpMoveFinder {
  static List<Move> findMoves(Piece piece, GameState gamestate) {
    var moves = new List<Move>();

    List<Tile> tiles = gamestate.toList();
    var tile = tiles.firstWhere((tile) => tile.piece == piece);
    for (var targetTile in tiles) {
      if (tile.coordinate.isAdjacent(targetTile.coordinate)) {
        var direction = tile.coordinate.direction(targetTile.coordinate);
        var jumpTile = targetTile;
        var targetCoordinate;
        do {
          targetCoordinate = jumpTile.coordinate.applyDirection(direction);
          jumpTile = tiles.firstWhere((tile) => tile.coordinate == targetCoordinate, orElse: () => null);
        } while (jumpTile != null);

        moves.add(new Move(piece, tile.coordinate, targetCoordinate));
      }
    }
    return moves;
  }
}
