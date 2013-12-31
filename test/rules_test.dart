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