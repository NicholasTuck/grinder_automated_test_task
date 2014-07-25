part of grinder_automated_test_task.grinder_automated_test_task;

class TestMainPreparer {
  Directory testDirectory = new Directory("test");

  TestMainPreparer({Directory testDirectory}) {
    if (testDirectory != null) this.testDirectory = testDirectory;
  }

  File generateTestMainFile() {
    File testMainFile = _createTestMainFile();
    List<String> testFilePaths = _getAllTestFilePaths();

    testMainFile.writeAsStringSync("""
    ${_getFileImports(testFilePaths)}

    void main() {
      ${_buildMainCalls(testFilePaths)}
    }
    """);

    return testMainFile;
  }

  File _createTestMainFile() {
    testDirectory.createSync();

    File testMainFile = new File(testDirectory.path + "/testMain.dart");
    if (testMainFile.existsSync()) testMainFile.deleteSync();
    testMainFile.createSync();
    return testMainFile;
  }

  List<String> _getAllTestFilePaths() {
    List<String> testFilePaths = _getFileList(testDirectory, '*Test.dart');
    testFilePaths.addAll(_getFileList(testDirectory, '*_test.dart'));
    return testFilePaths;
  }

  List<String> _getFileList(Directory baseDirectory, String pattern) {
    List<String> fileNames = [];
    FileSet sourceFiles = new FileSet.fromDir(baseDirectory, pattern: pattern, recurse: true);

    sourceFiles.files.forEach((File file) {
      // delete the test directory path so file names are relative to testMain.dart file
      String relativeFilePath = file.path.replaceFirst('${testDirectory.path}\\', '').replaceAll('${testDirectory.path}/', '');
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


}