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

var camera = new Camera();
Bench bench;
Piece selectedPiece;


void main() {
  var assetLibrary = new AssetLibrary();
  assetLibrary.downloadAssets().then((values) => start());
}

void start() {
  layoutCanvas();
  var gamestate = new GameState();

  FileUploadInputElement fileUpload = querySelector("#file-upload-id");
  fileUpload.onChange.listen((_) {
    var files = fileUpload.files;
    if (files.isEmpty) { return; }
    var file = files.first;
    var fileReader = new FileReader();
    fileReader..readAsText(file)
        ..onLoadEnd.listen((_) => setupSGF(fileReader.result, gamestate));
  });

  var nextControl = querySelector("#control-next-id");
  nextControl.onClick.listen((_) => showNextMove(gamestate));

  var previousControl= querySelector("#control-previous-id");
  previousControl.onClick.listen((_) => showPreviousMove(gamestate));

  var startControl = querySelector("#control-start-id");
  startControl.onClick.listen((_) => showFirstMove(gamestate));

  var endControl = querySelector("#control-end-id");
  endControl.onClick.listen((_) => showLastMove(gamestate));

  AnchorElement uploadLink = querySelector('#upload-anchor-id');
  uploadLink.onClick.listen((_) {
    fileUpload.click();
  });

  var isClick = false;
  var canvas = querySelector("#hive-canvas-id");
  canvas.onMouseDown.listen((event) {
    isClick = true;
  });
  canvas.onClick.listen((event) {
    if (isClick) {
      handleCanvasClick(event, gamestate);
    }
  });

  var dragHandler = new DragHandler(canvas);

  var adjustCamera = (DragEvent e) {
    var movement = e.mouseEvent.movement;
    camera.offsetX += movement.x;
    camera.offsetY += movement.y;
    render(gamestate);
  };

  dragHandler.onDragStart.listen((event) {
    isClick = false;
    adjustCamera(event);
  });
  dragHandler.onDrag.listen(adjustCamera);
  dragHandler.onDragEnd.listen(adjustCamera);

  window.onKeyDown.listen((event) => handleKeyPress(event, gamestate));
  window.onResize.listen((event) {
    layoutCanvas();
    render(gamestate);
  });

  SGF.downloadSGF().then((sgf) {
    setupSGF(sgf, gamestate);
  });
}

void handleKeyPress(KeyboardEvent event, GameState gamestate) {
  selectedPiece = null;

  switch (event.keyCode) {
    case 37: //left
      gamestate.stepBy(-1);
      break;
    case 38: //up
      gamestate.step(gamestate.moves.length);
      break;
    case 39: //right
      gamestate.stepBy(1);
      break;
    case 40: //down
      gamestate.step(1);
      break;
    default: return;
  }
  render(gamestate);
}

void handleCanvasClick(MouseEvent event, GameState gamestate) {
  var hexmap = new Hexmap(80, 90, .25);

  var canvas = querySelector("#hive-canvas-id");
  var initialTranslation = new Point(canvas.width / 4 - HexView.width / 4, canvas.height / 4 - HexView.height / 4 - Bench.height / 4);
  var translatedPoint = event.offset - new Point(camera.offsetX, camera.offsetY) - initialTranslation;
  var coordinate = hexAtPoint(hexmap, translatedPoint);

  List<Move> moves = [];
  Piece clickedPiece = gamestate.pieceAt(coordinate);
  if (clickedPiece == selectedPiece) {
    selectedPiece = null;
  } else {
    selectedPiece = clickedPiece;
  }

  render(gamestate);
}

void setupSGF(String sgf, GameState gamestate) {
  ParsedGame parsedGame = SGF.parseSGF(sgf);
  if (!parsedGame.valid) {
    var gameType = parsedGame.errors.join(", ");
    var plural = parsedGame.errors.length > 1 ? "s" : "";
    window.alert("Game type${plural} not supported: ${gameType}");
    return;
  }
  bench = new Bench(parsedGame.player1, parsedGame.player2);
  selectedPiece = null;
  gamestate.initialize(parsedGame.gameEvents);
  gamestate.step(1);
  render(gamestate);
}

void showNextMove(GameState gamestate) {
  selectedPiece = null;
  gamestate.stepBy(1);

  render(gamestate);
}

void showPreviousMove(GameState gamestate) {
  selectedPiece = null;
  gamestate.stepBy(-1);

  render(gamestate);
}

void showFirstMove(GameState gamestate) {
  selectedPiece = null;
  gamestate.step(1);

  render(gamestate);
}

void showLastMove(GameState gamestate) {
  selectedPiece = null;
  gamestate.stepToEnd();

  render(gamestate);
}

class Camera {
  num offsetX = 0, offsetY = 0;
}

void layoutCanvas() {
  DivElement header = querySelector('#header-id');
  DivElement progressBar = querySelector('#progress-bar-id');

  CanvasElement canvas = querySelector("#hive-canvas-id");
  var width = window.innerWidth;
  var height = window.innerHeight - header.clientHeight - progressBar.clientHeight;

  canvas.width = width * 2;
  canvas.height = height * 2;
  canvas.style.width = '${width}px';
  canvas.style.height = '${height}px';
}

void render(GameState gamestate) {
  CanvasElement canvas = querySelector("#hive-canvas-id");

  DivElement progressBar = querySelector("#progress-bar-indicator-id");
  progressBar.style.width = "${ canvas.width / 2 * gamestate.percentComplete - 2}px";

  var context = canvas.context2D;

  context.save();
  var gradient = context.createLinearGradient(0, 0, 0, canvas.height);
  gradient.addColorStop(0, '#F2E4B1');
  gradient.addColorStop(1, '#E3C68C');
  context.fillStyle = gradient;
  context.fillRect(0, 0, canvas.width, canvas.height);
  context.restore();

  context.save();

  context.translate(canvas.width / 2 - HexView.width / 2, (canvas.height - Bench.height) / 2 - HexView.height / 2);
  context.translate(camera.offsetX * 2, camera.offsetY * 2);

  List<TileView> tileViews = gamestate.toList().map((tile) => new TileView(tile, gamestate.piecesCoveredByTile(tile))).toList();
  List<Move> moves = [];
  if (selectedPiece != null) {
    moves.addAll(selectedPiece.moves(gamestate));
  }
  List<MoveView> moveViews = moves.map((move) => new MoveView(
      move.targetLocation,
      gamestate.stackAt(move.targetLocation).length)
  ).toList();

  List<HexView> hexViews = [];
  hexViews.addAll(tileViews);
  hexViews.addAll(moveViews);

  hexViews.sort((t1, t2) {
    var rowCompare = t1.row.compareTo(t2.row);
    if (rowCompare != 0) { return rowCompare; }

    var heightCompare = t1.stackHeight.compareTo(t2.stackHeight);
    if (heightCompare != 0) { return heightCompare; }

    var colCompare = t1.col.compareTo(t2.col);
    return colCompare;
  });

  for (HexView hexView in hexViews) {
      hexView.draw(context);
  }

  context.restore();

  bench.draw(context, canvas, gamestate);
}
