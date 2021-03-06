library gamemodel;

import 'gamestate.dart';
import 'rules.dart';
import 'move_finder.dart';

part 'piece_impl.dart';

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
  static const MOSQUITO = const Bug._internal('MOSQUITO');

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

      case 'm':
      case 'M': return Bug.MOSQUITO;
    }
    throw new Exception("Invalid bug: " + bug);
  }
}

class Piece {
  Player player;
  Bug bug;
  int bugCount;

  Piece._internal(this.player, this.bug, this.bugCount);

  factory Piece(player, bug, bugCount) {
    switch (bug) {
      case Bug.ANT:
        return new Ant._internal(player, bugCount);
      case Bug.BEETLE:
        return new Beetle._internal(player, bugCount);
      case Bug.GRASSHOPPER:
        return new Grasshopper._internal(player, bugCount);
      case Bug.QUEEN:
        return new Queen._internal(player, bugCount);
      case Bug.SPIDER:
        return new Spider._internal(player, bugCount);
      case Bug.MOSQUITO:
        return new Mosquito._internal(player, bugCount);
    }
  }

  bool operator ==(other) {
    if (other is !Piece) { return false; }
    return player == other.player && bug == other.bug && bugCount == other.bugCount;
  }

  int get hashCode {
    return player.hashCode ^ bug.hashCode ^ bugCount.hashCode;
  }

  List<Move> moves(GameState gamestate) {
    return RangedSlideMoveFinder.findMoves(3, this, gamestate);
  }

  String toString() => "Piece: (${player}, ${bug}, ${bugCount})";
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

  List<Coordinate> adjacentDirections() {
    switch (this) {
      case UP_RIGHT: return [ UP_LEFT, RIGHT ];
      case RIGHT: return [ UP_RIGHT, DOWN_RIGHT ];
      case DOWN_RIGHT: return [ RIGHT, DOWN_LEFT ];
      case DOWN_LEFT: return [ DOWN_RIGHT, LEFT ];
      case LEFT: return [ DOWN_LEFT, UP_LEFT ];
      case UP_LEFT: return [ LEFT, UP_RIGHT ];
      case ABOVE: return [ UP_RIGHT, RIGHT, DOWN_RIGHT, DOWN_LEFT, LEFT, UP_LEFT ];
    }
  }
}

class Coordinate {
  num row, col;
  Coordinate(this.row, this.col);

  Coordinate applyDirection(Direction direction) {
    switch(direction) {
      case Direction.UP_LEFT:
        return _evenRow ? new Coordinate(row - 1, col - 1) : new Coordinate(row - 1, col);
      case Direction.UP_RIGHT:
        return _evenRow ? new Coordinate(row - 1, col) : new Coordinate(row - 1, col + 1);
      case Direction.RIGHT:
        return new Coordinate(row, col + 1);
      case Direction.DOWN_RIGHT:
        return _evenRow ? new Coordinate(row + 1, col) : new Coordinate(row + 1, col + 1);
      case Direction.DOWN_LEFT:
        return _evenRow ? new Coordinate(row + 1, col - 1) : new Coordinate(row + 1, col);
      case Direction.LEFT:
        return new Coordinate(row, col - 1);
      case Direction.ABOVE:
        return new Coordinate(row, col);
    }
  }

  bool isAdjacent(Coordinate other) {
    for (var direction in Direction.all()) {
      if (direction == Direction.ABOVE) { continue; }

      if (applyDirection(direction) == other) { return true; }
    }
    return false;
  }

  Direction direction(Coordinate other) {
    for (var direction in Direction.all()) {
      if (applyDirection(direction) == other) {
        return direction;
      }
    }
    throw new Exception("Invalid coordinates");
  }

  bool operator ==(other) {
    if (other is !Coordinate) { return false; }
    return row == other.row && col == other.col;
  }

  int get hashCode {
    return row.hashCode ^ col.hashCode;
  }

  String toString() {
    return '(${row}, ${col})';
  }

  bool get _evenRow => row % 2 == 0;
}

class Tile {
  num row, col;
  Piece piece;
  int height;

  Tile(this.row, this.col, this.piece, { this.height: 0 });

  bool operator ==(other) {
    if (other is !Tile) { return false; }
    return row == other.row && col == other.col && piece == other.piece;
  }

  int get hashCode {
    return row.hashCode ^ col.hashCode ^ piece.hashCode;
  }

  Coordinate get coordinate => new Coordinate(row, col);
}

class GameEvent {
  Piece piece;

  Piece relativePiece;
  Direction direction;

  GameEvent(this.piece, this.relativePiece, this.direction);
}
