library gamemodel_test;

import 'package:unittest/unittest.dart';  

import '../lib/gamemodel.dart';

main() {
  test('Player equality', () {
    expect(Player.WHITE, equals(Player.WHITE));
    expect(Player.WHITE, isNot(equals(Player.BLACK)));
  });
  
  test('Bug equality', () {
    expect(Bug.ANT, equals(Bug.ANT));
    expect(Bug.ANT, isNot(equals(Bug.QUEEN)));
  });

  test('Direction equality', () {
    expect(Direction.LEFT, equals(Direction.LEFT));
    expect(Direction.LEFT, isNot(equals(Direction.RIGHT)));
  });

  test('Piece equality', () {
    expect(new Piece(Player.WHITE, Bug.ANT, 1), equals(new Piece(Player.WHITE, Bug.ANT, 1)));

    expect(new Piece(Player.WHITE, Bug.ANT, 1), isNot(equals(new Piece(Player.BLACK, Bug.ANT, 1))));
    expect(new Piece(Player.WHITE, Bug.ANT, 1), isNot(equals(new Piece(Player.WHITE, Bug.QUEEN, 1))));
    expect(new Piece(Player.WHITE, Bug.ANT, 1), isNot(equals(new Piece(Player.WHITE, Bug.ANT, 0))));
  });
  
  test('Piece hashCode', () {
    expect(new Piece(Player.WHITE, Bug.ANT, 1).hashCode, equals(new Piece(Player.WHITE, Bug.ANT, 1).hashCode));

    expect(new Piece(Player.WHITE, Bug.ANT, 1).hashCode, isNot(equals(new Piece(Player.BLACK, Bug.ANT, 1).hashCode)));
    expect(new Piece(Player.WHITE, Bug.ANT, 1).hashCode, isNot(equals(new Piece(Player.WHITE, Bug.QUEEN, 1).hashCode)));
    expect(new Piece(Player.WHITE, Bug.ANT, 1).hashCode, isNot(equals(new Piece(Player.WHITE, Bug.ANT, 0).hashCode)));
  });
}