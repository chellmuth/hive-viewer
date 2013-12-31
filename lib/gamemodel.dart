library gamemodel;

class Player {
  final _value;
  const Player._internal(this._value);
  toString() => 'Player.$_value';

  static const WHITE = const Player._internal('WHITE');
  static const BLACK = const Player._internal('BLACK');

  static Player parse(String player) {
    switch(player) {
      case '0':
      case 'w':
      case 'W': return Player.WHITE;
      
      case '1':
      case 'b':
      case 'B': return Player.BLACK;
    }

    throw new Exception("Invalid player: " + player);
  }
}

class Bug {
  final _value;
  const Bug._internal(this._value);
  toString() => 'Piece.$_value';

  static const ANT = const Bug._internal('ANT');
  static const QUEEN = const Bug._internal('QUEEN');
  static const BEETLE = const Bug._internal('BEETLE');
  static const SPIDER = const Bug._internal('SPIDER');
  static const GRASSHOPPER = const Bug._internal('GRASSHOPPER');
  
  static parse(String bug) {
    switch(bug) {
      case 'a':
      case 'A': return Bug.ANT;
      
      case 'q':
      case 'Q': return Bug.QUEEN;
      
      case 'b':
      case 'B': return Bug.BEETLE;
      
      case 's':
      case 'S': return Bug.SPIDER;
      
      case 'g':
      case 'G': return Bug.GRASSHOPPER;
    }
    throw new Exception("Invalid bug: " + bug);
  }
}

class Piece {
  Player player;
  Bug bug;
  num bugCount;
  
  Piece (this.player, this.bug, this.bugCount);
  
  bool operator ==(other) {
    if (other is !Piece) { return false; }
    return player == other.player && bug == other.bug && bugCount == other.bugCount; 
  }

  int get hashCode {
    // This is crappy because of overflowing integers -> doubles in Dart.
    int result = 17;
    result = 37 * result + player.hashCode;
    result = 37 * result + bug.hashCode;
    result = 37 * result + bugCount.hashCode;
    return result;
  }
}

class Direction {
  final _value;
  const Direction._internal(this._value);
  toString() => 'Direction.$_value';

  static const UP_RIGHT = const Direction._internal('UP_RIGHT');
  static const RIGHT = const Direction._internal('RIGHT');
  static const DOWN_RIGHT = const Direction._internal('DOWN_RIGHT');
  static const DOWN_LEFT = const Direction._internal('DOWN_LEFT');
  static const LEFT = const Direction._internal('LEFT');
  static const UP_LEFT = const Direction._internal('UP_LEFT');
  static const ABOVE = const Direction._internal('ABOVE');
  
  static List<Direction> all() {
    return [ 
      Direction.UP_RIGHT,
      Direction.RIGHT,
      Direction.DOWN_RIGHT,
      Direction.DOWN_LEFT,
      Direction.LEFT,
      Direction.UP_LEFT,
      Direction.ABOVE
    ];
  }
}

class GameEvent {
  Piece piece;
  
  Piece relativePiece;
  Direction direction;
    
  GameEvent(this.piece, this.relativePiece, this.direction);
}
