library gamestate;

import 'view.dart';
import 'gamemodel.dart';

class GameState {
  var tiles = [];
  
  void processEvents(List<GameEvent> events) {
    for (GameEvent event in events) {
      if (event.direction == null && event.relativePiece == null) {
        tiles.add(new Tile(0, 0, event.piece));
      }
    }
  }

  List<Tile> toList() {
    return tiles;
  }
}