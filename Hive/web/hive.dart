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
  canvas.width = 800;
  canvas.height = 600;
  
  var context = canvas.context2D;

  context.save();
  context.translate(canvas.width / 2 - Tile.width / 2, canvas.height / 2 - Tile.height / 2);

  for (Tile tile in gamestate.toList()) {
    tile.draw(context);
  }
  context.restore();
}

