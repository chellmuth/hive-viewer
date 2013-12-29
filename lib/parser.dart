library parser;

import 'dart:math';
import 'dart:async';
import 'dart:html';
import 'dart:convert';

import 'gamemodel.dart';

class SGF {
  static final Random random = new Random();

  static Future downloadSGF() {
    var path = 'sgf/test1.sgf';
    return HttpRequest.getString(path); 
  }
  
  static List<GameEvent> parseSGF(String SGFString) {
    var gameEvents = [];
    var lineSplitter = new LineSplitter();
    for (String line in lineSplitter.convert(SGFString)) {
      _parseLine(line, gameEvents);
    }

    return gameEvents;
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