library gamestate;

import 'view.dart';

class GameState {
  List<Tile> toList() {
    return [
      new Tile(2, 3),
      new Tile(3, 3),
      new Tile(3, 4)
    ];
  }
}