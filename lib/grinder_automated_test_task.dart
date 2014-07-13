library grinder_automated_test_task.grinder_automated_test_task;

import 'package:grinder/grinder.dart';
import 'package:path/path.dart' as Path;
import 'dart:io';


GrinderTask createAutomatedTestTask(String taskName, {List<String> depends: const [], Directory testDirectory}) {

  GrinderAutomatedTestTask automatedTestTask = new GrinderAutomatedTestTask(testDirectory);

  GrinderTask grinderTask = new GrinderTask(taskName, taskFunction: automatedTestTask.runTests, depends: depends, description: GrinderAutomatedTestTask.description);

  return grinderTask;
}

class GrinderAutomatedTestTask {
  static const String description = "Generates a 'test/testMain.dart' file test main of all 'test/**/*Test.dart' and 'test/**/*_test.dart' test files";

  Directory _testDirectory = new Directory("test");

  GrinderAutomatedTestTask(Directory testDirectory) {
    if (testDirectory != null) _testDirectory = testDirectory;
  }

  void runTests(GrinderContext context) {
    context.log("Starting Testing...");

    File testMainFile = _createTestMainFile();
    List<String> testFilePaths = _getAllTestFilePaths();

    testMainFile.writeAsStringSync("""
    ${_getFileImports(testFilePaths)}

    void main() {
      ${_buildMainCalls(testFilePaths)}
    }
    """);

    _runTestProcess(context, testMainFile);
  }

  File _createTestMainFile() {
    _testDirectory.createSync();

    File testMainFile = new File(_testDirectory.path + "/testMain.dart");
    if (testMainFile.existsSync()) testMainFile.deleteSync();
    testMainFile.createSync();
    return testMainFile;
  }

  List<String> _getAllTestFilePaths() {
    List<String> testFilePaths = _getFileList(_testDirectory, '*Test.dart');
    testFilePaths.addAll(_getFileList(_testDirectory, '*_test.dart'));
    return testFilePaths;
  }

  List<String> _getFileList(Directory baseDirectory, String pattern) {
    List<String> fileNames = [];
    FileSet sourceFiles = new FileSet.fromDir(baseDirectory, pattern: pattern, recurse: true);

    sourceFiles.files.forEach((File file) {
      // delete the test directory path so file names are relative to testMain.dart file
      String relativeFilePath = file.path.replaceFirst('${_testDirectory.path}\\', '').replaceAll('${_testDirectory.path}/', '');
      fileNames.add(relativeFilePath);
    });

    return fileNames;
  }

  String _getFileImports(List<String> testFilePaths) {
    String fileImports = '';
    testFilePaths.forEach((String testFilePath) {
      String safeAsParameter = _sanitizeFilePathForAsParameter(testFilePath);
      String correctFilePath = testFilePath.replaceAll("\\", "/");
      fileImports += "import '$correctFilePath' as $safeAsParameter;\n";
    });

    return fileImports;
  }

  static String _buildMainCalls(List<String> testFilePaths) {
    String mainCalls = '';
    testFilePaths.forEach((String testFilePath) {
      var safeAsParameter = _sanitizeFilePathForAsParameter(testFilePath);
      mainCalls += "$safeAsParameter.main();\n";
    });

    return mainCalls;
  }

  static String _sanitizeFilePathForAsParameter(String filePath) => filePath.replaceAll("\\", "").replaceAll("/", "").replaceAll("\.", "");

  void _runTestProcess(GrinderContext context, File testMainFile) {
    try {
      runDartScript(context, Path.basename(testMainFile.path), workingDirectory: _testDirectory.path);
    } catch (exception) {
      context.fail("Tests Failed!");
    }
  }
}
