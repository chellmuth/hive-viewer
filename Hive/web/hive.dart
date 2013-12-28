import 'dart:html';
import 'dart:math';
import 'dart:async';
import 'dart:convert';

import '../lib/gamestate.dart';
import '../lib/view.dart';
import '../lib/assets.dart';


void main() {
  var assetLibrary = new AssetLibrary();
  assetLibrary.downloadAssets().then((values) => start());
}

void start() {
  SGF.prepareSGF().then((value) => print(value));
  render();
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

class Player {
  final _value;
  const Player._internal(this._value);
  toString() => 'Player.$_value';

  static const WHITE = const Player._internal('WHITE');
  static const BLACK = const Player._internal('BLACK');

  static Player parse(String player) {
    switch(player) {
      case '0':
      case 'w':
      case 'W': return Player.WHITE;
      
      case '1':
      case 'b':
      case 'B': return Player.BLACK;
    }

    throw new Exception("Invalid player: " + player);
  }
}

class Bug {
  final _value;
  const Bug._internal(this._value);
  toString() => 'Piece.$_value';

  static const ANT = const Bug._internal('ANT');
  static const QUEEN = const Bug._internal('QUEEN');
  static const BEETLE = const Bug._internal('BEETLE');
  static const SPIDER = const Bug._internal('SPIDER');
  static const GRASSHOPPER = const Bug._internal('GRASSHOPPER');
  
  static parse(String bug) {
    switch(bug) {
      case 'a':
      case 'A': return Bug.ANT;
      
      case 'q':
      case 'Q': return Bug.QUEEN;
      
      case 'b':
      case 'B': return Bug.BEETLE;
      
      case 's':
      case 'S': return Bug.SPIDER;
      
      case 'g':
      case 'G': return Bug.GRASSHOPPER;
    }
    throw new Exception("Invalid bug: " + bug);
  }
}

class Piece {
  Player player;
  Bug bug;
  num bugCount;
  
  Piece (this.player, this.bug, this.bugCount);
}

class Direction {
  final _value;
  const Direction._internal(this._value);
  toString() => 'Direction.$_value';

  static const UP = const Direction._internal('UP');
  static const UP_RIGHT = const Direction._internal('UP_RIGHT');
  static const RIGHT = const Direction._internal('RIGHT');
  static const DOWN_RIGHT = const Direction._internal('DOWN_RIGHT');
  static const DOWN = const Direction._internal('DOWN');
  static const DOWN_LEFT = const Direction._internal('DOWN_LEFT');
  static const LEFT = const Direction._internal('LEFT');
  static const UP_LEFT = const Direction._internal('UP_LEFT');
  static const ABOVE = const Direction._internal('ABOVE');
}

class GameEvent {
  Piece piece;
  
  Piece relativePiece;
  Direction direction;
    
  GameEvent(this.piece, this.relativePiece, this.direction);
}

class SGF {
  static final Random random = new Random();

  static Future prepareSGF() {
    var path = 'sgf/test1.sgf';
    return HttpRequest.getString(path)
        .then(_parseSGF);
  }
  
  static String _parseSGF(String SGFString) {
    var gameEvents = [];
    var lineSplitter = new LineSplitter();
    for (String line in lineSplitter.convert(SGFString)) {
      _parseLine(line, gameEvents);
    }

    return "the future is now";
  }
  
  static _parseLine(String line, List<GameEvent> gameEvents) {
    if (!line.startsWith(';')) {
      return;
    }
    var playerMoveExp = new RegExp(r"; P(\d)\[\d+ pdropb ([wb])([abgqs])([123])? \w+ \d+ ([^\]]+)]");
    var match = playerMoveExp.firstMatch(line);
    if (match != null) {
      print(line);
      gameEvents.add(_parseGameEvent(match));
      return;
    }

    var computerMoveExp = new RegExp(r"; P(\d)\[\d+ move ([WB]) ([ABGQS])([123])? \w+ \d+ ([^\]]+)\]");
    var computerMatch = computerMoveExp.firstMatch(line);
    if (computerMatch != null) {
      print(line);
      gameEvents.add(_parseGameEvent(computerMatch));
      return;
    }
  }

  static GameEvent _parseGameEvent(Match match) {
    var player = match.group(1);
    var color = match.group(2);
    var bug = match.group(3);
    var bugCount = match.group(4);
    var relativeTo = match.group(5);
    
    var piece = new Piece(Player.parse(color), Bug.parse(bug), _parseBugCount(bugCount));
    var relativePiece = _parseRelativePiece(relativeTo);
    var direction = _parseDirection(relativeTo);
    
    return new GameEvent(piece, relativePiece, direction);
  }
  
  static num _parseBugCount(String bugCount) {
    if (bugCount == null) { return 0; }
    return int.parse(bugCount, radix: 10);
  }
  
  static Piece _parseRelativePiece(String relativeTo) {
    var pieceExp = new RegExp(r"([wb])([ABGQS])([123])?");
    var match = pieceExp.firstMatch(relativeTo);
    if (match != null) {
      var color = match.group(1);
      var bug = match.group(2);
      var bugCount = match.group(3);
      return new Piece(Player.parse(color), Bug.parse(bug), _parseBugCount(bugCount));
    }
    return null;
  }
  
  static Direction _parseDirection(String relativeTo) {
    if (relativeTo == '.') { return null; }
    if (relativeTo.startsWith('-')) { return Direction.LEFT; }
    if (relativeTo.startsWith('\\')) { return Direction.UP_LEFT; }
    if (relativeTo.startsWith('/')) { return Direction.DOWN_LEFT; }
    if (relativeTo.endsWith('-')) { return Direction.RIGHT; }
    if (relativeTo.endsWith('\\')) { return Direction.DOWN_RIGHT; }
    if (relativeTo.endsWith('/')) { return Direction.UP_RIGHT; }
    
    return Direction.ABOVE;
  }
  
}