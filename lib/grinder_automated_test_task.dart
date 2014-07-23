library grinder_automated_test_task.grinder_automated_test_task;

import 'dart:io';
import 'package:grinder/grinder.dart';
import 'package:path/path.dart' as Path;
import 'package:browser_unittest/browser_unittest.dart';
import 'package:ansicolor/ansicolor.dart';


part "src/grinder_automated_test_task.dart";
part "src/grinder_headless_test_task.dart";
part "src/test_main_preparer.dart";


GrinderTask createAutomatedTestTask(String taskName, {List<String> depends: const [], Directory testDirectory}) {
  GrinderAutomatedTestTask automatedTestTask = new GrinderAutomatedTestTask(testDirectory);
  GrinderTask grinderTask = new GrinderTask(taskName, taskFunction: automatedTestTask.runTests, depends: depends, description: GrinderAutomatedTestTask.description);
  return grinderTask;
}

GrinderTask createHeadlessTestTask(String taskName, {List<String> depends: const [], Directory testDirectory}) {
  GrinderHeadlessTestTask grinderHeadlessTestTask = new GrinderHeadlessTestTask(testDirectory);
  GrinderTask grinderTask = new GrinderTask(taskName, taskFunction: grinderHeadlessTestTask.runTests, depends: depends, description: GrinderHeadlessTestTask.description);
  return grinderTask;
}