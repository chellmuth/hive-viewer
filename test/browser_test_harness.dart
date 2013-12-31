library hive_test;

import 'package:unittest/unittest.dart';  
import 'package:unittest/html_config.dart';

import '../lib/rules.dart';
import '../lib/gamemodel.dart';
import '../lib/gamestate.dart';
import '../lib/view.dart';
import '../lib/move_finder.dart';

part 'rules_test.dart';
part 'gamestate_test.dart';
part 'move_finder_test.dart';

main() {
  useHtmlConfiguration();
  TestRules.run();
  TestGameState.run();
  TestMoveFinder.run();
}