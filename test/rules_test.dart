part of hive_test;

class TestRules {
  static void run() {
    group('Rules:', () {
      group('One Hive Rule:', _oneHiveRule);
      group('Freedom Of Movement Rule:', _freedomOfMovementRule);
      group('Constant Contact Rule:', _constantContactRule);
    });
  }

  static void _oneHiveRule() {
    test('single piece', () {
      Piece piece = new Piece(Player.WHITE, Bug.ANT, 1);
      GameState gamestate = new GameState();
      gamestate.initialize([ new GameEvent(piece, null, null) ]);
      gamestate.step(1);

      Move move = new Move(piece, new Coordinate(0, 0), new Coordinate(0, 1));
      expect(checkOneHiveRule(move, gamestate), isTrue);
    });

    test('two adjacent pieces', () {
      Piece piece1 = new Piece(Player.WHITE, Bug.ANT, 1);
      Piece piece2 = new Piece(Player.BLACK, Bug.ANT, 1);
      GameState gamestate = new GameState();
      gamestate.initialize([
        new GameEvent(piece1, null, null),
        new GameEvent(piece2, piece1, Direction.RIGHT)
      ]);
      gamestate.step(2);

      Move move = new Move(piece1, new Coordinate(0, 0), new Coordinate(0, 2));
      expect(checkOneHiveRule(move, gamestate), isTrue);
    });

    test('two disjoint pieces', () {
      Piece piece1 = new Piece(Player.WHITE, Bug.ANT, 1);
      Piece piece2 = new Piece(Player.BLACK, Bug.ANT, 1);
      GameState gamestate = new GameState();
      gamestate.initialize([
        new GameEvent(piece1, null, null),
        new GameEvent(piece2, piece1, Direction.RIGHT)
      ]);
      gamestate.step(2);

      Move move = new Move(piece1, new Coordinate(0, 0), new Coordinate(0, 3));
      expect(checkOneHiveRule(move, gamestate), isNot(isTrue));
    });

    test('moving the piece causes a temporary hive split', () {
      var _bA_ = new Piece(Player.WHITE, Bug.ANT, 1);
      var gamestate = GameStateTestHelper.build([
        [ '  ', '  ', 'wG', '  ', '  ' ],
          [ '  ', _bA_, '  ', '  ', '  ' ],
        [ '  ', 'wG', '  ', 'wG', '  ' ],
          [ '  ', 'wG', 'wG', '  ', '  ' ]
      ]);
      gamestate.stepToEnd();
      Piece piece = _bA_;
      Move move = new Move(piece, new Coordinate(1, 1), new Coordinate(1, 2));
      expect(checkOneHiveRule(move, gamestate), isNot(isTrue));
    });
  }

  static void _freedomOfMovementRule() {
    test('true', () {
      expect(true, isTrue);
    });
  }

  static void _constantContactRule() {
    test('true', () {
      expect(true, isTrue);
    });
  }
}

class GameStateTestHelper {
  static GameState build(List<List> rows) {
    var bugCount = 1000; // don't collide with bugCount of passed in bugs
    var moves = new List<Move>();
    for (int rowIndex = 0; rowIndex < rows.length; rowIndex++) {
      var row = rows[rowIndex];
      for (int colIndex = 0; colIndex < row.length; colIndex++) {
        var value = row[colIndex];
        if (value is String) {
          if (value.trim().isEmpty) { continue; }
          Player player = Player.parse(value[0]);
          Bug bug = Bug.parse(value[1]);
          var piece = new Piece(player, bug, bugCount++);
          moves.add(new Move(piece, null, new Coordinate(rowIndex, colIndex)));
        } else if (value is Piece) {
          moves.add(new Move(value as Piece, null, new Coordinate(rowIndex, colIndex)));
        }
      }
    }

    GameState gamestate = new GameState();
    for (Move move in moves) {
      gamestate.appendMove(move);
    }
    return gamestate;
  }
}