part of hive_test;

class TestGameState {
  static void run() {
    group('Game State:', () {
      group('Copy:', _copy);
      group('Append GameEvent:', _appendGameEvent);
      group('Step to end:', _stepToEnd);
      group('Locate:', _locate);
      group('Neighbors:', _neighbors);
    });
    group('Coordinate:', _coordinate);
  }

  static void _copy() {
    test('initially equal', () {
      Piece piece1 = new Piece(Player.WHITE, Bug.ANT, 1);
      Piece piece2 = new Piece(Player.BLACK, Bug.ANT, 1);
      GameState gamestate1 = new GameState();
      gamestate1.initialize([
        new GameEvent(piece1, null, null),
        new GameEvent(piece2, piece1, Direction.RIGHT)
      ]);
      gamestate1.step(2);

      GameState gamestate2 = gamestate1.copy();
      expect(gamestate1.toList(), equals(gamestate2.toList()));
    });

    test('unequal after step change', () {
      Piece piece1 = new Piece(Player.WHITE, Bug.ANT, 1);
      Piece piece2 = new Piece(Player.BLACK, Bug.ANT, 1);
      GameState gamestate1 = new GameState();
      gamestate1.initialize([
        new GameEvent(piece1, null, null),
        new GameEvent(piece2, piece1, Direction.RIGHT)
      ]);
      gamestate1.step(2);

      GameState gamestate2 = gamestate1.copy();
      gamestate2.step(1);

      expect(gamestate1.toList(), isNot(equals(gamestate2.toList())));
    });

    test('unequal after append move', () {
      Piece piece1 = new Piece(Player.WHITE, Bug.ANT, 1);
      GameState gamestate1 = new GameState();
      gamestate1.initialize([
        new GameEvent(piece1, null, null)
      ]);

      GameState gamestate2 = gamestate1.copy();

      Piece piece2 = new Piece(Player.BLACK, Bug.ANT, 1);
      gamestate2.appendMove(new Move(piece2, null, new Coordinate(0, 1)));

      gamestate1.step(2);
      gamestate2.step(2);
      expect(gamestate1.toList(), isNot(equals(gamestate2.toList())));
    });
  }

  static void _appendGameEvent() {
    test('return correct tiles', () {
      Piece piece1 = new Piece(Player.WHITE, Bug.ANT, 1);
      GameState gamestate = new GameState();
      gamestate.initialize([
        new GameEvent(piece1, null, null)
      ]);

      Piece piece2 = new Piece(Player.BLACK, Bug.ANT, 1);
      gamestate.appendMove(new Move(piece2, null, new Coordinate(0, 1)));
      gamestate.step(2);
      expect(gamestate.toList(), equals([ new Tile(0, 0, piece1), new Tile(0, 1, piece2) ]));
    });
  }

  static void _stepToEnd() {
    test('basic', () {
      Piece piece1 = new Piece(Player.WHITE, Bug.ANT, 1);
      Piece piece2 = new Piece(Player.BLACK, Bug.ANT, 1);
      GameState gamestate = new GameState();
      gamestate.initialize([
        new GameEvent(piece1, null, null),
        new GameEvent(piece2, piece1, Direction.RIGHT)
      ]);
      gamestate.stepToEnd();
      expect(gamestate.toList().length, equals(2));
    });  
  }

  static void _locate() {
    test('basic', () {
      Piece piece1 = new Piece(Player.WHITE, Bug.ANT, 1);
      Piece piece2 = new Piece(Player.BLACK, Bug.ANT, 1);
      GameState gamestate = new GameState();
      gamestate.initialize([
        new GameEvent(piece1, null, null),
        new GameEvent(piece2, piece1, Direction.RIGHT)
      ]);
      gamestate.stepToEnd();
      gamestate.appendMove(new Move(piece1, new Coordinate(0, 0), new Coordinate(1, 1)));
      gamestate.stepToEnd();
      
      expect(gamestate.locate(piece1), equals(new Coordinate(1, 1)));
      expect(gamestate.locate(piece2), equals(new Coordinate(0, 1)));
    });
  }
  
  static void _neighbors() {
    test('basic', () {
      var _bG_ = new Piece(Player.BLACK, Bug.GRASSHOPPER, 1);
      var gamestate = GameStateTestHelper.build([
        [ 'wG', '  ', '  ', '  ' ],
          [ '  ', 'bA', 'wA', '  ' ],
        [ '  ', 'bQ', _bG_, 'wQ' ],
          [ '  ', 'bB', 'wB', '  ' ],
        [ '  ', '  ', '  ', 'wG' ]
      ]);
      gamestate.stepToEnd();
      var piece = _bG_;
      expect(gamestate.neighbors(piece).length, equals(6));
    });
  }
  
  static void _coordinate() {
    test('equality', () {
      expect(new Coordinate(20, 100), equals(new Coordinate(20, 100)));
      expect(new Coordinate(20, 100), isNot(equals(new Coordinate(20, 20))));
      expect(new Coordinate(20, 100), isNot(equals(new Coordinate(100, 100))));
    });
    
    test('direction', () {
      expect(new Coordinate(10, 12).direction(new Coordinate(9, 12)), equals(Direction.UP_RIGHT));
      expect(new Coordinate(9, 12).direction(new Coordinate(8, 12)), equals(Direction.UP_LEFT));
    });

    test('adjacent even row', () {
      Coordinate c = new Coordinate(2, 6);
      var adjacentCoordinates = [
        new Coordinate(2, 5), // start left, move clockwise
        new Coordinate(1, 5),
        new Coordinate(1, 6),
        new Coordinate(2, 7),
        new Coordinate(3, 5),
        new Coordinate(3, 6)
      ];
      for (var adjacentCoordinate in adjacentCoordinates) {
        expect(c.isAdjacent(adjacentCoordinate), isTrue);
      }

      var nonAdjacentCoordinates = [
        new Coordinate(2, 6),
        new Coordinate(2, 4),
        new Coordinate(2, 8),
        new Coordinate(1, 4),
        new Coordinate(1, 7),
        new Coordinate(3, 4),
        new Coordinate(3, 7)
      ];
      for (var nonAdjacentCoordinate in nonAdjacentCoordinates) {
        expect(c.isAdjacent(nonAdjacentCoordinate), isNot(isTrue));
      }
    });

    test('adjacent odd row', () {
      Coordinate c = new Coordinate(3, 6);
      var adjacentCoordinates = [
        new Coordinate(3, 5), // start left, move clockwise
        new Coordinate(2, 6),
        new Coordinate(2, 7),
        new Coordinate(3, 7),
        new Coordinate(4, 6),
        new Coordinate(4, 7)
      ];
      for (var adjacentCoordinate in adjacentCoordinates) {
        expect(c.isAdjacent(adjacentCoordinate), isTrue);
      }

      var nonAdjacentCoordinates = [
        new Coordinate(3, 6),
        new Coordinate(3, 4),
        new Coordinate(3, 8),
        new Coordinate(2, 5),
        new Coordinate(2, 8),
        new Coordinate(4, 5),
        new Coordinate(4, 8)
      ];
      for (var nonAdjacentCoordinate in nonAdjacentCoordinates) {
        expect(c.isAdjacent(nonAdjacentCoordinate), isNot(isTrue));
      }
    });
  }
}