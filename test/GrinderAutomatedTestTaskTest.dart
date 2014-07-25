library grinder_automated_test_task.grinder_automated_test_task_test;

import 'package:unittest/unittest.dart';
import 'package:grinder_automated_test_task/grinder_automated_test_task.dart';
import 'package:grinder/Grinder.dart';
import 'dart:io';

// useful resource: https://www.dartlang.org/articles/dart-unit-tests/#matchers

main() {

  Directory testDirectory = new Directory('exampleTests');

  group("Creating Headless Test Main Files", () {
    Grinder grinder = new Grinder();
    grinder.addTask(createHeadlessTestTask('testHeadless', testDirectory: testDirectory));
    grinder.start(['testHeadless']);

    test("should create headless test main dart file", () {
      List<File> files = new FileSet.fromDir(testDirectory, pattern: 'testMainHeadless.dart').files;
      expect(files, hasLength(1));
    });
    test("should create headless test main html file", () {
      List<File> files = new FileSet.fromDir(testDirectory, pattern: 'testMainHeadless.html').files;
      expect(files, hasLength(1));
    });
  });

  group("Creating Test Main File", () {
    Grinder grinder = new Grinder();
    grinder.addTask(createAutomatedTestTask('testExampleDirectory', testDirectory: testDirectory));
    grinder.start(['testExampleDirectory']);

    test("should create test main file", () {
      List<File> files = new FileSet.fromDir(testDirectory, pattern: 'testMain.dart').files;
      expect(files, hasLength(1));
    });

    test("should have same number of imports as their are test files", () {
      File testMain = new FileSet.fromDir(testDirectory, pattern: 'testMain.dart').files.first;
      String testMainString = testMain.readAsStringSync();
      Iterable<Match> matches = 'import'.allMatches(testMainString);
      expect(matches.length, equals(2));
    });

    test("should have same number of main calls as their are test files", () {
      File testMain = new FileSet.fromDir(testDirectory, pattern: 'testMain.dart').files.first;
      String testMainString = testMain.readAsStringSync();
      Iterable<Match> matches = '.main()'.allMatches(testMainString);
      expect(matches.length, equals(2));
    });


  });
}
