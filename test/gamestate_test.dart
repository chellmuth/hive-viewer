part of hive_test;

class TestGameState {
  static void run() {
    group('Game State:', () {
      group('Copy:', _copy);
      group('Append GameEvent:', _appendGameEvent);
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
    
    test('unequal after append game event', () {
      Piece piece1 = new Piece(Player.WHITE, Bug.ANT, 1);
      GameState gamestate1 = new GameState();
      gamestate1.initialize([ 
        new GameEvent(piece1, null, null)
      ]);

      GameState gamestate2 = gamestate1.copy();

      Piece piece2 = new Piece(Player.BLACK, Bug.ANT, 1);
      gamestate2.appendGameEvent(new GameEvent(piece2, piece1, Direction.RIGHT));
      
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
      gamestate.appendGameEvent(new GameEvent(piece2, piece1, Direction.RIGHT));
      gamestate.step(2);
      expect(gamestate.toList(), equals([ new Tile(0, 0, piece1), new Tile(0, 1, piece2) ]));
    });
  }
}