import 'dart:html';
import 'dart:async';

import '../lib/gamestate.dart';
import '../lib/view.dart';
import '../lib/assets.dart';
import '../lib/parser.dart';

var stepCount = 1;

void main() {
  var assetLibrary = new AssetLibrary();
  assetLibrary.downloadAssets().then((values) => start());
}

void start() {    
  var gamestate = new GameState();

  var nextButton = querySelector("#button_next_id");
  nextButton.onClick.listen((_) => showNextMove(gamestate));

  var previousButton = querySelector("#button_previous_id");
  previousButton.onClick.listen((_) => showPreviousMove(gamestate));

  SGF.downloadSGF().then((sgf) {
    var gameEvents = SGF.parseSGF(sgf);
    gamestate.initialize(gameEvents);
    gamestate.step(stepCount);
    render(gamestate);
    
    nextButton.disabled = false;
    previousButton.disabled = false;
  });
}

void showNextMove(GameState gamestate) {
  stepCount += 1;
  gamestate.step(stepCount);
  
  render(gamestate);
}

void showPreviousMove(GameState gamestate) {
  stepCount -= 1;
  gamestate.step(stepCount);
  
  render(gamestate);
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

