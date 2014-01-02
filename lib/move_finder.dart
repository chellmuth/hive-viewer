library move_finder;

import 'dart:collection';

import 'gamemodel.dart';
import 'gamestate.dart';
import 'rules.dart';
import 'view.dart';

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
  static List<Move> findMoves(int range, Piece piece, GameState gamestate) {
    var startingLocation = gamestate.locate(piece);
    gamestate = gamestate.copy();

    var finalLocations = new Set<Coordinate>();

    var transitionLists = [ [ gamestate.locate(piece) ] ];
    gamestate.toList().removeWhere((tile) => tile.piece == piece);
    for (int i = 0; i < range; i++) {
      var nextTransitionLists = [];
      for (List<Coordinate> transitionList in transitionLists) {
        Coordinate lastTransition = transitionList.last;
        for (Tile neighbor in gamestate.neighbors(lastTransition)) {
          var neighborDirection = lastTransition.direction(neighbor.coordinate);
          for (var transitionDirection in neighborDirection.adjacentDirections()) {
            var newLocation = lastTransition.applyDirection(transitionDirection);
            if (gamestate.isLocationEmpty(newLocation)) {
              var newTransitionList = new List<Coordinate>.from(transitionList);
              newTransitionList.add(newLocation);
              nextTransitionLists.add(newTransitionList);
            }
          }
        }
      }
      transitionLists = nextTransitionLists;
    }

    for (List<Coordinate> transition in transitionLists) {
      if (new Set<Coordinate>.from(transition).length == range + 1) {
        finalLocations.add(transition.last);
      }
    }
    return finalLocations.map((location) => new Move(piece, startingLocation, location)).toList();    
  } 
}