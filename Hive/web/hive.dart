import 'dart:html';

import '../lib/gamestate.dart';
import '../lib/view.dart';
import '../lib/assets.dart';


void main() {
  var assetLibrary = new AssetLibrary();
  assetLibrary.downloadAssets().then((values) => render());
}

void render() {
  CanvasElement canvas = querySelector("#hive_canvas_id");
  canvas.width = 500;
  canvas.height = 500;
  
  var context = canvas.context2D;
  var gamestate = new GameState();
  for (Tile tile in gamestate.toList()) {
    tile.draw(context);
  }
}

