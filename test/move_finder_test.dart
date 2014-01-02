part of hive_test;

class TestMoveFinder {
  static void run() {
    group('Move Finder:', () {
      group('Jump Finder:', _jumpFinder);
      group('Ranged Slide Finder:', _rangedSlideFinder);
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

    group('jump respects one hive rule', () {
      test('basic hive split', () {
        var _bG_ = new Piece(Player.BLACK, Bug.GRASSHOPPER, 1);
        var gamestate = GameStateTestHelper.build([
          [ '  ', 'bA', _bG_, 'bA', '  ' ]
        ]);
        gamestate.stepToEnd();

        var piece = _bG_;
        var moves = JumpMoveFinder.findMoves(piece, gamestate);
        expect(moves.isEmpty, isTrue);
      });

      test('hive only splits during the jump', () {
        var _bG_ = new Piece(Player.BLACK, Bug.GRASSHOPPER, 1);

        // wA gets isolated during jump into __
        var gamestate = GameStateTestHelper.build([
          [ '  ', 'bA', '__', '  ' ],
            [ 'bA', '  ', 'wA', '  ' ],
          [ '  ', 'bA', '  ', _bG_ ],
            [ '  ', 'bA', 'bA', '  ' ]
        ]);
        gamestate.stepToEnd();

        var piece = _bG_;
        var moves = JumpMoveFinder.findMoves(piece, gamestate);
        expect(moves.firstWhere((move) => move.targetLocation == new Coordinate(0, 2), orElse: () => null), isNull);
      });
    });
  }
  
  static void _rangedSlideFinder() {
    test('slide once around a single piece', () {
        var _bQ_ = new Piece(Player.BLACK, Bug.QUEEN, 1);
        var gamestate = GameStateTestHelper.build([
          [ '  ', '  ' ],
            [ 'bA', _bQ_ ],
          [ '  ', '  ' ]
        ]);
        gamestate.stepToEnd();
      
        var piece = _bQ_;
        var moves = RangedSlideMoveFinder.findMoves(1, piece, gamestate);
        var moveCoordinates = [
          new Coordinate(2, 1),
          new Coordinate(0, 1)
        ];

        expect(moves.map((move) => move.targetLocation).toList(), equals(moveCoordinates));
    });
    test('slide twice around a single piece', () {
        var _bQ_ = new Piece(Player.BLACK, Bug.QUEEN, 1);
        var gamestate = GameStateTestHelper.build([
          [ '  ', '  ', '  ' ],
            [ '  ', 'bA', _bQ_ ],
          [ '  ', '  ', '  ' ]
        ]);
        gamestate.stepToEnd();
      
        var piece = _bQ_;
        var moves = RangedSlideMoveFinder.findMoves(2, piece, gamestate);
        var moveCoordinates = [
          new Coordinate(2, 1),
          new Coordinate(0, 1)
        ];

        expect(moves.map((move) => move.targetLocation).toList(), equals(moveCoordinates));
    });

  }
}
