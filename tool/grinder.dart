import 'dart:io';
import 'package:grinder/grinder.dart';
import 'package:grinder_automated_test_task/grinder_automated_test_task.dart';

void main([List<String> args]) {
  defineTask('init', taskFunction: init);
  addTask(createAutomatedTestTask('test', depends: ['init']));

  startGrinder(args);
}

init(GrinderContext context) {
  if (sdkDir == null || !sdkDir.existsSync()) {
    print('[ERROR]  Environment variable DART_SDK must be set to `your/path/to/dart/dart-sdk`');
    exit(2);
  }

  PubTools pub = new PubTools();
  pub.get(context);
}
