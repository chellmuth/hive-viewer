import 'dart:html';
import 'dart:async';

import '../lib/gamestate.dart';
import '../lib/view.dart';
import '../lib/assets.dart';
import '../lib/parser.dart';


void main() {
  var assetLibrary = new AssetLibrary();
  assetLibrary.downloadAssets().then((values) => start());
}

void start() {
  var gamestate = new GameState();
  SGF.downloadSGF().then((sgf) {
    var gameEvents = SGF.parseSGF(sgf);
    gamestate.processEvents(gameEvents);
    render(gamestate);
  });
}

void render(GameState gamestate) {
  CanvasElement canvas = querySelector("#hive_canvas_id");
  canvas.width = 500;
  canvas.height = 500;
  
  var context = canvas.context2D;
  for (Tile tile in gamestate.toList()) {
    tile.draw(context);
  }
}

