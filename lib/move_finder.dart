library move_finder;

import 'dart:collection';

import 'gamemodel.dart';
import 'gamestate.dart';
import 'rules.dart';


List<Move> validMovesForPiece(Piece piece, GameState gamestate) {
  return [];
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

      if (_checkRulesOnTransition(transition, gamestate)) {
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

  static bool _checkRulesOnTransition(List<Coordinate> transition, GameState gamestate) {
    gamestate = gamestate.copy();
    Coordinate currentLocation = transition.first;
    Piece piece = gamestate.pieceAt(currentLocation);
    for (Coordinate targetLocation in transition.sublist(1)) {
      Move move = new Move(piece, currentLocation, targetLocation);
      if (!checkOneHiveRule(move, gamestate)) { return false; }
      if (!checkFreedomOfMovementRule(move, gamestate)) { return false; }

      gamestate.appendMove(move);
      gamestate.stepToEnd();
      currentLocation = targetLocation;
    }
    return true;
  }
}