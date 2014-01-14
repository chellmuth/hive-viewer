library parser;

import 'dart:async';
import 'dart:html';
import 'dart:convert';

import 'gamemodel.dart';

class ParsedGame {
  String player1;
  String player2;
  List<GameEvent> gameEvents = [];

  bool valid = true;
  List<String> errors = [];

  List<Bug> expansionBugs = [];
}

class SGF {
  static Future downloadSGF() {
    var path = 'sgf/test1.sgf';
    return HttpRequest.getString(path);
  }

  static ParsedGame parseSGF(String SGFString) {
    var game = new ParsedGame();
    var lineSplitter = new LineSplitter();
    for (String line in lineSplitter.convert(SGFString)) {
      _parseLine(line, game);
    }

    return game;
  }

  static _parseLine(String line, ParsedGame game) {
    var gameTypeExp = new RegExp(r'^SU\[hive(-\w+)\]');
    var gameTypeMatch = gameTypeExp.firstMatch(line);
    if (gameTypeMatch != null) {
      var gameType = gameTypeMatch.group(1);
      if (gameType.contains("ultimate")) {
        game.errors.add("Ultimate");
        game.valid = false;
      } else {
        if (gameType.contains("m")) {
          game.expansionBugs.add(Bug.MOSQUITO);
        }
        if (gameType.contains("l")) {
          game.errors.add("Ladybug");
          game.valid = false;
        }
        if (gameType.contains("p")) {
          game.errors.add("Pillbug");
          game.valid = false;
        }
      }
    }

    var playerNameExp = new RegExp(r'P([01])\[id "([^"]+)"\]');
    var playerNameMatch = playerNameExp.firstMatch(line);
    if (playerNameMatch != null) {
      var playerNumber = int.parse(playerNameMatch.group(1));
      var playerName = playerNameMatch.group(2);

      if (playerNumber == 0) {
        game.player1 = playerName;
      } else if (playerNumber == 1) {
        game.player2 = playerName;
      } else {
        throw new Exception("Unknown player number");
      }
      return;
    }

    var playerMoveExp = new RegExp(r"; P(\d)\[\d+ p?dropb ([wb])([AaBbGgQqSsMm])([123])? \w+ \d+ ([^\]]+)]");
    var match = playerMoveExp.firstMatch(line);
    if (match != null) {
      game.gameEvents.add(_parseGameEvent(match));
      return;
    }

    var computerMoveExp = new RegExp(r"; P(\d)\[\d+ move ([WB]) [wb]?([ABGQSM])([123])? \w+ \d+ ([^\]]+)\]");
    var computerMatch = computerMoveExp.firstMatch(line);
    if (computerMatch != null) {
      game.gameEvents.add(_parseGameEvent(computerMatch));
      return;
    }
  }

  static GameEvent _parseGameEvent(Match match) {
    var player = match.group(1);
    var color = match.group(2);
    var bug = match.group(3);
    var bugCount = match.group(4);
    var relativeTo = match.group(5);

    var bugType = Bug.parse(bug);
    var piece = new Piece(Player.parse(color), bugType, _parseBugCount(bugCount, bugType));
    var relativePiece = _parseRelativePiece(relativeTo);
    var direction = _parseDirection(relativeTo);
    return new GameEvent(piece, relativePiece, direction);
  }

  static num _parseBugCount(String bugCount, Bug bugType) {
    if (bugCount == null) {
      switch (bugType) {
        case Bug.ANT:
        case Bug.BEETLE:
        case Bug.GRASSHOPPER:
        case Bug.SPIDER:
        case Bug.MOSQUITO:
          return 1;
        case Bug.QUEEN:
          return 0;
      }
    }
    return int.parse(bugCount, radix: 10);
  }

  static Piece _parseRelativePiece(String relativeTo) {
    var pieceExp = new RegExp(r"([wb])([ABGQSM])([123])?");
    var match = pieceExp.firstMatch(relativeTo);
    if (match != null) {
      var color = match.group(1);
      var bug = match.group(2);
      var bugCount = match.group(3);
      var bugType = Bug.parse(bug);
      return new Piece(Player.parse(color), bugType, _parseBugCount(bugCount, bugType));
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