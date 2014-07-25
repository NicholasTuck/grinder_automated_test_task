part of grinder_automated_test_task.grinder_automated_test_task;

class GrinderHeadlessTestTask {
  static const String description = "Generates a 'test/testMain.dart' file test main of all 'test/**/*Test.dart' and 'test/**/*_test.dart' test files and runs them via chromiums `contentShell test/testMainHeadless.html`";

  final _colorizeAsError = new AnsiPen()..red();
  final _colorizeAsFailure = new AnsiPen()..red();
  final _colorizeAsSuccess = new AnsiPen()..green();


  TestMainPreparer testMainPreparer;

  GrinderHeadlessTestTask(Directory testDirectory) {
    testMainPreparer = new TestMainPreparer(testDirectory);
  }

  void runTests(GrinderContext context) {
    context.log("Starting Testing...");

    File testMainFile = testMainPreparer.generateTestMainFile();
    testMainPreparer.copyHeadlessTestMainDart();
    testMainPreparer.copyHeadlessTestMainHtml();

    _runContentShellHeadless(context);
  }

  _runContentShellHeadless(GrinderContext context) {
    String contentShellCommand = 'content_shell';
    try {
      ProcessResult processResult = Process.runSync(contentShellCommand, ['--dump-render-tree', 'test/testMainHeadless.html']);
      var run = htmlConfigParser(processResult.stdout);

      if (run.didComplete) {
        var passes = run.results.where((result) => result.isPass);
        var errors = run.results.where((result) => result.isError);
        var failures = run.results.where((result) => result.isFailure);

        errors.forEach((error) => _logTestFailure(error, context));
        failures.forEach((failure) => _logTestFailure(failure, context));

        var summary = 'Test results: ${passes.length} passed, ${failures.length} failed, ${errors.length} errored';
        if (errors.isNotEmpty || failures.isNotEmpty) {
          context.fail(_colorizeAsError(summary));
        } else {
          context.log(_colorizeAsSuccess(summary));
        }
      } else {
        context.log(_colorizeAsError('Tests did not complete '));
        context.fail(run.errorOutput);
      }
    } on GrinderException catch (e) {
      throw e;
    } catch (e) {
      context.fail('Unable to find $contentShellCommand on the path.');
    }
  }

  void _logTestFailure(TestResult testResult, GrinderContext context) {
    context.log("${testResult.description}\n${testResult.stackTrace}");
  }
}
