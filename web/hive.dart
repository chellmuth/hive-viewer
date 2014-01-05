import 'dart:html';
import 'dart:async';

import 'package:drag_handler/drag_handler.dart';

import '../lib/gamestate.dart';
import '../lib/view.dart';
import '../lib/assets.dart';
import '../lib/parser.dart';
import '../lib/hex_math.dart';
import '../lib/gamemodel.dart';
import '../lib/rules.dart';

var stepCount = 1;
var camera = new Camera();

void main() {
  var assetLibrary = new AssetLibrary();
  assetLibrary.downloadAssets().then((values) => start());
}

void start() {
  var gamestate = new GameState();

  FileUploadInputElement fileUpload = querySelector("#file_upload_id");
  fileUpload.onChange.listen((_) {
    var files = fileUpload.files;
    if (files.isEmpty) { return; }
    var file = files.first;
    var fileReader = new FileReader();
    fileReader..readAsText(file)
        ..onLoadEnd.listen((_) => setupSGF(fileReader.result, gamestate));
  });

  var nextButton = querySelector("#button_next_id");
  nextButton.onClick.listen((_) => showNextMove(gamestate));

  var previousButton = querySelector("#button_previous_id");
  previousButton.onClick.listen((_) => showPreviousMove(gamestate));

  var firstButton = querySelector("#button_first_id");
  firstButton.onClick.listen((_) => showFirstMove(gamestate));
  
  var canvas = querySelector("#hive_canvas_id");

  canvas.onClick.listen((event) => handleCanvasClick(event, gamestate));
  
  var dragHandler = new DragHandler(canvas);
  
  var adjustCamera = (DragEvent e) {
    var movement = e.mouseEvent.movement;
    camera.offsetX += movement.x;
    camera.offsetY += movement.y;
    render(gamestate);
  };
  dragHandler.onDragStart.listen(adjustCamera);
  dragHandler.onDrag.listen(adjustCamera);
  
  window.onKeyDown.listen((event) => handleKeyPress(event, gamestate)); 

  SGF.downloadSGF().then((sgf) {
    setupSGF(sgf, gamestate);

    nextButton.disabled = false;
    previousButton.disabled = false;
    firstButton.disabled = false;
  });
}

void handleKeyPress(KeyboardEvent event, GameState gamestate) {
  switch (event.keyCode) {
    case 37: //left
      stepCount -= 1;
      break;
    case 38: //up
      stepCount = 1;
      break;
    case 39: //right
      stepCount += 1;
      break;
    case 40: //down
      stepCount = gamestate.moves.length;
      break;
    default: return;
  }
  gamestate.step(stepCount);
  render(gamestate);
}

void handleCanvasClick(MouseEvent event, GameState gamestate) {
  var hexmap = new Hexmap(80, 90, .25);

  var canvas = querySelector("#hive_canvas_id");
  var initialTranslation = new Point(canvas.width / 2 - HexView.width / 2, canvas.height / 2 - HexView.height / 2);
  var translatedPoint = event.offset - new Point(camera.offsetX, camera.offsetY) - initialTranslation;
  var coordinate = hexAtPoint(hexmap, translatedPoint);
  
  List<Move> moves = [];
  for (Tile tile in gamestate.toList()) {
    if (tile.coordinate == coordinate) {
      tile.highlight = true;
      moves.addAll(tile.piece.moves(gamestate));
    } else {
      tile.highlight = false;
    }
  }
  render(gamestate, moves: moves);
}

void setupSGF(String sgf, GameState gamestate) {
  stepCount = 1;
  var gameEvents = SGF.parseSGF(sgf);
  gamestate.initialize(gameEvents);
  gamestate.step(stepCount);
  render(gamestate);
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

void render(GameState gamestate, { List<Move> moves : null }) {
  CanvasElement canvas = querySelector("#hive_canvas_id");

  var context = canvas.context2D;
  
  context.save();
  var gradient = context.createLinearGradient(0, 0, 0, canvas.height);
  gradient.addColorStop(0, '#F2E4B1');
  gradient.addColorStop(1, '#E3C68C');
  context.fillStyle = gradient;
  context.fillRect(0, 0, canvas.width, canvas.height);
  context.restore();

  context.save();
  context.translate(canvas.width / 2 - HexView.width / 2, canvas.height / 2 - HexView.height / 2);
  context.translate(camera.offsetX * 2, camera.offsetY * 2);

  List<TileView> tileViews = gamestate.toList().map((tile) => new TileView(tile)).toList();
  tileViews.sort((t1, t2) {
    var rowCompare = t1.row.compareTo(t2.row);
    if (rowCompare != 0) { return rowCompare; }

    return t1.col.compareTo(t2.col);
  });
  print(tileViews.map((tileView) => tileView.tile.coordinate));

  for (TileView tileView in tileViews) {
    if (!tileView.tile.highlight) {
      tileView.draw(context);
    }
  }

  if (moves == null) { moves = []; }
  Iterable<MoveView> moveViews = moves.map((move) => new MoveView(move.targetLocation));
  for (var moveView in moveViews) {
    moveView.draw(context);
  }
  
  for (TileView tileView in tileViews) {
    if (tileView.tile.highlight) {
      tileView.draw(context);
    }
  }

  context.restore();
}

