part of grinder_automated_test_task.grinder_automated_test_task;


class GrinderAutomatedTestTask {
  static const String description = "Generates a 'test/testMain.dart' file test main of all 'test/**/*Test.dart' and 'test/**/*_test.dart' test files and runs them via `dart test/testMain.dart`";

  TestMainPreparer testMainPreparer;

  GrinderAutomatedTestTask(Directory testDirectory) {
    testMainPreparer = new TestMainPreparer(testDirectory);
  }

  void runTests(GrinderContext context) {
    context.log("Starting Testing...");

    File testMainFile = testMainPreparer.generateTestMainFile();

    _runTestProcess(context, testMainFile);
  }

  void _runTestProcess(GrinderContext context, File testMainFile) {
    try {
      runDartScript(context, Path.basename(testMainFile.path), workingDirectory: testMainPreparer.testDirectory.path);
    } catch (exception) {
      context.fail("Tests Failed!");
    }
  }


}
