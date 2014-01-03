library move_finder;

import 'dart:collection';

import 'gamemodel.dart';
import 'gamestate.dart';
import 'rules.dart';


List<Move> validMovesForPiece(Piece piece, GameState gamestate) {
  return [];
}

bool _checkSlideRulesOnTransition(List<Coordinate> transition, GameState gamestate) {
  gamestate = gamestate.copy();
  Coordinate currentLocation = transition.first;
  Piece piece = gamestate.pieceAt(currentLocation);
  for (Coordinate targetLocation in transition.sublist(1)) {
    Move move = new Move(piece, currentLocation, targetLocation);
    if (!checkOneHiveRule(move, gamestate)) { return false; }
    if (!checkFreedomOfMovementRule(move, gamestate)) { return false; }

    gamestate.appendMove(move);
    gamestate.stepBy(1);
    currentLocation = targetLocation;
  }
  return true;
}


class JumpMoveFinder {
  static List<Move> findMoves(Piece piece, GameState gamestate) {
    var moves = new List<Move>();

    List<Tile> tiles = gamestate.toList();
    var tile = tiles.firstWhere((tile) => tile.piece == piece);
    for (var targetTile in tiles) {
      if (tile.coordinate.isAdjacent(targetTile.coordinate)) {
        var direction = tile.coordinate.direction(targetTile.coordinate);
        var jumpTile = targetTile;
        var targetCoordinate;
        do {
          targetCoordinate = jumpTile.coordinate.applyDirection(direction);
          jumpTile = tiles.firstWhere((tile) => tile.coordinate == targetCoordinate, orElse: () => null);
        } while (jumpTile != null);

        moves.add(new Move(piece, tile.coordinate, targetCoordinate));
      }
    }
    
    return moves.where((move) => checkOneHiveRule(move, gamestate)).toList();
  }
}

class SlideMoveFinder {
  static List<Move> findMoves(Piece piece, GameState gamestate) {
    var startingLocation = gamestate.locate(piece);

    var moveLocations = new Set<Coordinate>();
    var nextLocations = _extendMoveLocations(new Set<Coordinate>.from([startingLocation]), startingLocation, gamestate);
    while (!nextLocations.isEmpty) {
      moveLocations.addAll(nextLocations);
      nextLocations = _extendMoveLocations(moveLocations, startingLocation, gamestate);
    }

    return moveLocations.map((coordinate) => new Move(piece, startingLocation, coordinate)).toList();
  }

  static Set<Coordinate> _extendMoveLocations(Set<Coordinate> moveLocations, Coordinate startingLocation, GameState gamestate) {
    var newLocations = new Set<Coordinate>();
    for (Coordinate location in moveLocations) {
      for (Tile neighbor in gamestate.neighbors(location)) {
        var neighborDirection = location.direction(neighbor.coordinate);
        for (var transitionDirection in neighborDirection.adjacentDirections()) {
          var newLocation = location.applyDirection(transitionDirection);
          if (gamestate.isLocationEmpty(newLocation)
              && !moveLocations.contains(newLocation)
          ) {
            var originalGamestate = gamestate;
            gamestate = gamestate.copy();
            gamestate.appendMove(new Move(gamestate.pieceAt(startingLocation), startingLocation, newLocation));
            gamestate.stepBy(1);
            if(_checkSlideRulesOnTransition([ location, newLocation ], gamestate)) {
              newLocations.add(newLocation);
            }
            gamestate = originalGamestate;
          }
        }
      }
    }
    return newLocations;
  }
}

class RangedSlideMoveFinder {
  static List<List<Coordinate>> _extendTransitionList(List<Coordinate> transitionList, GameState gamestate) {
    var transitionLists = new List<List<Coordinate>>();
    Coordinate lastTransition = transitionList.last;
    for (Tile neighbor in gamestate.neighbors(lastTransition)) {
      var neighborDirection = lastTransition.direction(neighbor.coordinate);
      for (var transitionDirection in neighborDirection.adjacentDirections()) {
        var newLocation = lastTransition.applyDirection(transitionDirection);
        if (gamestate.isLocationEmpty(newLocation)) {
          var newTransitionList = new List<Coordinate>.from(transitionList);
          newTransitionList.add(newLocation);
          transitionLists.add(newTransitionList);
        }
      }
    }
    return transitionLists;
  }
  
  static List<List<Coordinate>> _buildTransitionLists(int range, Piece piece, GameState gamestate) {
    gamestate = gamestate.copy();

    var transitionLists = [ [ gamestate.locate(piece) ] ];
    gamestate.toList().removeWhere((tile) => tile.piece == piece);

    for (int i = 0; i < range; i++) {
      var nextTransitionLists = [];
      for (List<Coordinate> transitionList in transitionLists) {
        nextTransitionLists.addAll(_extendTransitionList(transitionList, gamestate));
      }
      transitionLists = nextTransitionLists;
    }
    return transitionLists;
  }

  static Set<Coordinate> _buildMoveLocationsFromTransitionLists(List<List<Coordinate>> transitionLists, GameState gamestate) {
    var moveLocations = new Set<Coordinate>();
    for (List<Coordinate> transition in transitionLists) {
      Coordinate destinationLocation = transition.last;
      if (moveLocations.contains(destinationLocation)) { continue; }
      if (new Set<Coordinate>.from(transition).length != transition.length) { continue; }

      if (_checkSlideRulesOnTransition(transition, gamestate)) {
        moveLocations.add(transition.last);
      }
    }
    return moveLocations;
  }

  static List<Move> findMoves(int range, Piece piece, GameState gamestate) {
    var startingLocation = gamestate.locate(piece);

    List<List<Coordinate>> transitionLists = _buildTransitionLists(range, piece, gamestate); 
    Set<Coordinate> moveLocations = _buildMoveLocationsFromTransitionLists(transitionLists, gamestate);

    return moveLocations.map((location) => new Move(piece, startingLocation, location)).toList();    
  }
}