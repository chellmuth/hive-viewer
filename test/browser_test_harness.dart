library hive_test;

import 'package:unittest/unittest.dart';  
import 'package:unittest/html_config.dart';

import '../lib/rules.dart';
import '../lib/gamemodel.dart';
import '../lib/gamestate.dart';

part 'rules_test.dart';

main() {
  useHtmlConfiguration();
  TestRules.run();
}