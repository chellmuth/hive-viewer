library hex_math;

import 'dart:math';

import 'gamemodel.dart';

class Hexmap {
  num width;
  num height;

  // fraction of height of one point
  num pointHeight;

  Hexmap(this.width, this.height, this.pointHeight);
}

Coordinate hexAtPoint(Hexmap hexmap, Point point) {
  var radius = 0;
  while (true) {
    List<Coordinate> ring = hexRing(radius);
    for (Coordinate hex in ring) {
      if (checkHex(hexmap, hex, point)) {
        return hex;
      }
    }
    radius += 1;
  }
}

List<Coordinate> hexRing(int radius) {
  var hexes = new List<Coordinate>();

  // start right, then move counter-clockwise around
  hexes.add(new Coordinate(0, radius));

  for (var i = 0; i < radius; i++) {
    hexes.add(hexes.last.applyDirection(Direction.UP_LEFT));
  }
  for (var i = 0; i < radius; i++) {
    hexes.add(hexes.last.applyDirection(Direction.LEFT));
  }
  for (var i = 0; i < radius; i++) {
    hexes.add(hexes.last.applyDirection(Direction.DOWN_LEFT));
  }
  for (var i = 0; i < radius; i++) {
    hexes.add(hexes.last.applyDirection(Direction.DOWN_RIGHT));
  }
  for (var i = 0; i < radius; i++) {
    hexes.add(hexes.last.applyDirection(Direction.RIGHT));
  }
  // note i < radius - 1 constraint to avoid re-adding initial coordinate
  for (var i = 0; i < radius - 1; i++) {
    hexes.add(hexes.last.applyDirection(Direction.UP_RIGHT));
  }

  return hexes;
}

bool _checkPointInTriangle(Point point, Point t0, Point t1, Point t2) {
  num compute_area(t0, t1, t2) {
    return 1 / 2 * (-t1.y * t2.x + t0.y * (-t1.x + t2.x) + t0.x * (t1.y - t2.y) + t1.x * t2.y);
  }

  var area = compute_area(t0, t1, t2);

  num s = 1 / (2 * area) * (t0.y * t2.x - t0.x * t2.y + (t2.y - t0.y) * point.x + (t0.x - t2.x) * point.y);
  num t = 1 / (2 * area) * (t0.x * t1.y - t0.y * t1.x + (t0.y - t1.y) * point.x + (t1.x - t0.x) * point.y);

  return s > 0 && t > 0 && 1 - s - t > 0;
}

bool checkHex(Hexmap hexmap, Coordinate hex, Point point) {
  num xOffset = hex.row % 2 == 0 ? 0 : hexmap.width * .5;
  Rectangle hexRect = new Rectangle(
      xOffset + hexmap.width * hex.col,
      hexmap.height * (.75 * hex.row + hexmap.pointHeight),
      hexmap.width,
      hexmap.height * (1 - 2 * hexmap.pointHeight)
  );
  if (hexRect.containsPoint(point)) { return true; }

  Point upperLeft = new Point(hexRect.left, hexRect.top);
  Point upperMiddle = new Point(hexRect.left + hexmap.width * .5, hexRect.top - hexmap.height * hexmap.pointHeight);
  Point upperRight = new Point(hexRect.right, hexRect.top);
  if (_checkPointInTriangle(point, upperLeft, upperMiddle, upperRight)) { return true; }

  Point lowerLeft = new Point(hexRect.left, hexRect.bottom);
  Point lowerMiddle = new Point(hexRect.left + hexmap.width * .5, hexRect.bottom + hexmap.height * hexmap.pointHeight);
  Point lowerRight = new Point(hexRect.right, hexRect.bottom);
  if (_checkPointInTriangle(point, lowerLeft, lowerMiddle, lowerRight)) { return true; }

  return false;
}