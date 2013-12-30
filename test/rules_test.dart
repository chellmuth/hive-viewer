part of hive_test;

class TestRules {
  static void run() {
    test('One Hive Rule', () {
      
      Piece piece = new Piece(Player.WHITE, Bug.ANT, 1);
      GameState gamestate = new GameState();
      gamestate.initialize([ new GameEvent(piece, null, null) ]);
      
      Move move = new Move(piece, new Coordinate(0, 0), new Coordinate(0, 1));
      expect(checkOneHiveRule(move, gamestate), isTrue);
    });
  }
}