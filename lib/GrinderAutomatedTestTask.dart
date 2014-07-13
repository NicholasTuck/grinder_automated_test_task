library automated.test.grinder.task;

import 'package:grinder/grinder.dart';
import 'dart:io';

GrinderTask createAutomatedTestTask(String taskName, {List<String> depends: const []} ) {
  GrinderTask task = new GrinderTask(taskName, taskFunction: AutomatedTestGrinderTask.runTests , depends: depends, description: AutomatedTestGrinderTask.description);

  return task;
}

class AutomatedTestGrinderTask {
  static const String description = "Generates a 'test/testMain.dart' file test main of all 'test/**/*Test.dart' and 'test/**/*_test.dart' test files";

  static void runTests(GrinderContext context) {
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

  static File _createTestMainFile() {
    Directory testOutputDirectory = new Directory("test");
    testOutputDirectory.createSync();

    File testMainFile = new File(testOutputDirectory.path + "/testMain.dart");
    if (testMainFile.existsSync()) testMainFile.delete();
    testMainFile.createSync();
    return testMainFile;
  }

  static List<String> _getAllTestFilePaths() {
    Directory testDirectory = new Directory('test');
    List<String> testFilePaths = getFileList(testDirectory, '*Test.dart');
    testFilePaths.addAll(getFileList(testDirectory, '*_test.dart'));
    return testFilePaths;
  }

  static List<String> getFileList(Directory baseDirectory, String pattern) {
    List<String> fileNames = [];
    FileSet sourceFiles = new FileSet.fromDir(baseDirectory, pattern: pattern, recurse: true);

    sourceFiles.files.forEach((file) {
      fileNames.add(file.path);
    });

    return fileNames;
  }

  static String _getFileImports(List<String> testFilePaths) {
    String fileImports = '';
    testFilePaths.forEach((String testFilePath) {
      String safeAsParameter = _sanitizeFilePathForAsParameter(testFilePath);
      String correctFilePath = testFilePath.replaceAll("\\", "/");
      fileImports += "import '../$correctFilePath' as $safeAsParameter;\n";
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

  static void _runTestProcess(GrinderContext context, File testMainFile) {
    try {
      runDartScript(context, testMainFile.path);
    } catch (exception) {
      context.fail("Tests Failed!");
    }
  }
}
