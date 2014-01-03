part of hive_console_test;

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
    test('can move through door', () {
      var _bA_ = new Piece(Player.WHITE, Bug.ANT, 1);
      // attempt to move through door into __
      var gamestate = GameStateTestHelper.build([
        [ '  ', '  ', _bA_ ],
          [ 'wG', '__', 'wG' ],
        [ '  ', 'wG', 'wG' ]
      ]);
      gamestate.stepToEnd();
      Piece piece = _bA_;
      Move move = new Move(piece, new Coordinate(0, 2), new Coordinate(1, 1));
      expect(checkFreedomOfMovementRule(move, gamestate), isTrue);
    });

    test('cannot move through gate', () {
      var _bA_ = new Piece(Player.WHITE, Bug.ANT, 1);
      // attempt to move through gate into __
      var gamestate = GameStateTestHelper.build([
        [ '  ', 'wG', 'wG' ],
          [ 'wG', '__', _bA_ ],
        [ '  ', 'wG', 'wG' ]
      ]);
      gamestate.stepToEnd();
      Piece piece = _bA_;
      Move move = new Move(piece, new Coordinate(1, 2), new Coordinate(1, 1));
      expect(checkFreedomOfMovementRule(move, gamestate), isNot(isTrue));
    });
  }

  static void _constantContactRule() {
    test('not maintaining constant contact', () {
      var _bA_ = new Piece(Player.WHITE, Bug.ANT, 1);
      // attempt to move into __ without constant contact
      var gamestate = GameStateTestHelper.build([
        [ '  ', 'wG', 'wG' ],
          [ 'wG', '  ', 'wG' ],
        [ '  ', '__', _bA_ ]
      ]);
      gamestate.stepToEnd();
      Piece piece = _bA_;
      Move move = new Move(piece, new Coordinate(2, 2), new Coordinate(2, 1));
      expect(checkConstantContactRule(move, gamestate), isNot(isTrue));
    });

    test('maintain constant contact', () {
      var _bA_ = new Piece(Player.WHITE, Bug.ANT, 1);
      var gamestate = GameStateTestHelper.build([
        [ 'wG', 'wG' ],
          [ '__', _bA_ ],
        [ '  ', '  ']
      ]);
      gamestate.stepToEnd();
      Piece piece = _bA_;
      Move move = new Move(piece, new Coordinate(1, 1), new Coordinate(1, 0));
      expect(checkConstantContactRule(move, gamestate), isTrue);
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
          if (value == '__') { continue; }
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
      gamestate.stepToEnd();
    }
    return gamestate;
  }
}