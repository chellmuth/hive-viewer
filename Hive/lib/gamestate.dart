library gamestate;

import 'view.dart';
import 'gamemodel.dart';

class GameState {
  void processEvents(List<GameEvent> events) {
  }
  List<Tile> toList() {
    return [
      new Tile(2, 3),
      new Tile(3, 3),
      new Tile(3, 4)
    ];
  }
}