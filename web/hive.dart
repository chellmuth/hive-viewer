import 'dart:html';
import 'dart:async';

import 'package:drag_handler/drag_handler.dart';

import '../lib/gamestate.dart';
import '../lib/view.dart';
import '../lib/assets.dart';
import '../lib/parser.dart';

var stepCount = 1;
var camera = new Camera();

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

  var firstButton = querySelector("#button_first_id");
  firstButton.onClick.listen((_) => showFirstMove(gamestate));
  
  var canvas = querySelector("#hive_canvas_id");
  var dragHandler = new DragHandler(canvas);
  
  var adjustCamera = (DragEvent e) {
    var movement = e.mouseEvent.movement;
    camera.offsetX += movement.x;
    camera.offsetY += movement.y;
    render(gamestate);
  };
  dragHandler.onDragStart.listen(adjustCamera);
  dragHandler.onDrag.listen(adjustCamera);

  SGF.downloadSGF().then((sgf) {
    var gameEvents = SGF.parseSGF(sgf);
    gamestate.initialize(gameEvents);
    gamestate.step(stepCount);
    render(gamestate);
    
    nextButton.disabled = false;
    previousButton.disabled = false;
    firstButton.disabled = false;
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

void showFirstMove(GameState gamestate) {
  stepCount = 1;
  gamestate.step(stepCount);
  
  render(gamestate);
}

class Camera {
  num offsetX = 0, offsetY = 0;
}

void render(GameState gamestate) {
  CanvasElement canvas = querySelector("#hive_canvas_id");
  canvas.width = 800;
  canvas.height = 600;
  
  var context = canvas.context2D;

  context.save();
  context.translate(canvas.width / 2 - Tile.width / 2, canvas.height / 2 - Tile.height / 2);
  context.translate(camera.offsetX, camera.offsetY);

  for (Tile tile in gamestate.toList()) {
    tile.draw(context);
  }
  context.restore();
}

