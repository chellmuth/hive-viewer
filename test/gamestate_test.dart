part of hive_console_test;

class TestGameState {
  static void run() {
    group('Game State:', () {
      group('Copy:', _copy);
      group('Append GameEvent:', _appendGameEvent);
      group('Step to end:', _stepToEnd);
      group('Locate:', _locate);
      group('Neighbors:', _neighbors);
      group('Piece At:', _pieceAt);
      group('Is Location Empty:', _isLocationEmpty);
      group('Stack at:', _stackAt);
    });
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
      expect(gamestate.neighbors(new Coordinate(2, 2)).length, equals(6));
    });
  }

  static void _pieceAt() {
    test('piece exists', () {
      Piece piece1 = new Piece(Player.WHITE, Bug.ANT, 1);
      Piece piece2 = new Piece(Player.BLACK, Bug.ANT, 1);
      GameState gamestate = new GameState();
      gamestate.initialize([
        new GameEvent(piece1, null, null),
        new GameEvent(piece2, piece1, Direction.RIGHT)
      ]);
      gamestate.stepToEnd();

      expect(gamestate.pieceAt(new Coordinate(0, 0)), equals(piece1));
      expect(gamestate.pieceAt(new Coordinate(0, 1)), equals(piece2));
    });

    test('piece doesn\'t exists', () {
      Piece piece = new Piece(Player.WHITE, Bug.ANT, 1);
      GameState gamestate = new GameState();
      gamestate.initialize([
        new GameEvent(piece, null, null)
      ]);
      gamestate.stepToEnd();

      expect(gamestate.pieceAt(new Coordinate(1, 0)), isNull);
    });
  }

  static void _isLocationEmpty() {
    test('location not empty', () {
      Piece piece1 = new Piece(Player.WHITE, Bug.ANT, 1);
      Piece piece2 = new Piece(Player.BLACK, Bug.ANT, 1);
      GameState gamestate = new GameState();
      gamestate.initialize([
        new GameEvent(piece1, null, null),
        new GameEvent(piece2, piece1, Direction.RIGHT)
      ]);
      gamestate.stepToEnd();

      expect(gamestate.isLocationEmpty(new Coordinate(0, 0)), isNot(isTrue));
      expect(gamestate.isLocationEmpty(new Coordinate(0, 1)), isNot(isTrue));
    });

    test('location is empty', () {
      Piece piece = new Piece(Player.WHITE, Bug.ANT, 1);
      GameState gamestate = new GameState();
      gamestate.initialize([
        new GameEvent(piece, null, null)
      ]);
      gamestate.stepToEnd();

      expect(gamestate.isLocationEmpty(new Coordinate(1, 0)), isTrue);
    });
  }

  static void _stackAt() {
    test('basic', () {
      Piece piece1 = new Piece(Player.WHITE, Bug.ANT, 1);
      Piece piece2 = new Piece(Player.BLACK, Bug.ANT, 1);
      GameState gamestate = new GameState();
      gamestate.initialize([
        new GameEvent(piece1, null, null),
        new GameEvent(piece2, piece1, Direction.RIGHT)
      ]);
      gamestate.stepToEnd();

      expect(gamestate.stackAt(new Coordinate(0, 0)), equals([piece1]));
      gamestate.appendMove(new Move(piece1, new Coordinate(0, 0), new Coordinate(0, 1)));
      gamestate.stepToEnd();
      expect(gamestate.stackAt(new Coordinate(0, 1)), equals([piece2, piece1]));
    });
  }
}