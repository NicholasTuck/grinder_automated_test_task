library grinder_automated_test_task.grinder_automated_test_task_test;

import 'package:unittest/unittest.dart';
import 'package:grinder_automated_test_task/GrinderAutomatedTestTask.dart';
import 'package:grinder/Grinder.dart';
import 'dart:io';

// useful resource: https://www.dartlang.org/articles/dart-unit-tests/#matchers

main() {
  Grinder grinder;

  Directory testDirectory = new Directory('exampleTests');

  setUp(() {
    grinder = new Grinder();
    grinder.addTask(createAutomatedTestTask('test', testDirectory: testDirectory));
  });

  tearDown(() => print('Tearing Down\n'));

  group("Creating Test Main File", () {

    test("should create test main file", () {
      grinder.start(['test']);

      List<File> files = new FileSet.fromDir(testDirectory, pattern: 'testMain.dart').files;
      expect(files, hasLength(1));
    });

    test("should have same number of imports as their are test files", () {
      grinder.start(['test']);

      File testMain = new FileSet.fromDir(testDirectory, pattern: 'testMain.dart').files.first;
      String testMainString = testMain.readAsStringSync();
      Iterable<Match> matches = 'import'.allMatches(testMainString);
      expect(matches.length, equals(2));
    });

    test("should have same number of main calls as their are test files", () {
      grinder.start(['test']);

      File testMain = new FileSet.fromDir(testDirectory, pattern: 'testMain.dart').files.first;
      String testMainString = testMain.readAsStringSync();
      Iterable<Match> matches = '.main()'.allMatches(testMainString);
      expect(matches.length, equals(2));
    });


  });
}
