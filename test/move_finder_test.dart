part of hive_test;

class TestMoveFinder {
  static void run() {
    group('Move Finder:', () {
      group('Jump Finder:', _jumpFinder);
    });
  }

  static void _jumpFinder() {
    test('one piece jumps', () {
      var _bG_ = new Piece(Player.BLACK, Bug.GRASSHOPPER, 1);
      var gamestate = GameStateTestHelper.build([
        [ '  ', '  ', '  ', '  ', '  ' ],
          [ '  ', 'bA', 'bA', '  ', '  ' ],
        [ '  ', 'bA', _bG_, 'bA', '  ' ],
          [ '  ', 'bA', 'bA', '  ', '  ' ],
        [ '  ', '  ', '  ', '  ', '  ' ]
      ]);
      gamestate.stepToEnd();
      var piece = _bG_;
      var moves = JumpMoveFinder.findMoves(piece, gamestate);
      var initialCoordinate = new Coordinate(2, 2);
      var expected_moves = [
        new Move(_bG_, initialCoordinate, new Coordinate(0, 1)),
        new Move(_bG_, initialCoordinate, new Coordinate(0, 3)),
        new Move(_bG_, initialCoordinate, new Coordinate(2, 0)),
        new Move(_bG_, initialCoordinate, new Coordinate(2, 4)),
        new Move(_bG_, initialCoordinate, new Coordinate(4, 1)),
        new Move(_bG_, initialCoordinate, new Coordinate(4, 3))
      ];

      expect(moves.toSet(), equals(expected_moves.toSet()));
    });

    // may need to re-write this one after One Hive is added to findMoves
    test('can\'t jump without adjacent pieces', () {
      var _bG_ = new Piece(Player.BLACK, Bug.GRASSHOPPER, 1);
      var gamestate = GameStateTestHelper.build([
        [ '  ', 'bA', '  ', 'bA', '  ' ],
          [ '  ', '  ', '  ', '  ', '  ' ],
        [ 'bA', '  ', _bG_, '  ', 'bA' ],
          [ '  ', '  ', '  ', '  ', '  ' ],
        [ '  ', 'bA', '  ', 'bA', '  ' ]
      ]);
      gamestate.stepToEnd();

      var piece = _bG_;
      var moves = JumpMoveFinder.findMoves(piece, gamestate);
      expect(moves.isEmpty, isTrue);
    });
  }
}
