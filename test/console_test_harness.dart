library hive_console_test;

import 'package:unittest/unittest.dart';  

import 'dart:math';

import '../lib/rules.dart';
import '../lib/gamemodel.dart';
import '../lib/gamestate.dart';
import '../lib/move_finder.dart';
import '../lib/hex_math.dart';


part 'rules_test.dart';
part 'gamestate_test.dart';
part 'move_finder_test.dart';
part 'hex_math_test.dart';
part 'gamemodel_test.dart';

main() {
  TestRules.run();
  TestGameState.run();
  TestMoveFinder.run();
  TestHexMath.run();
  TestGameModel.run();
}