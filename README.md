# grinder_automated_test_task

A grinder task that will generate a test file which will run all test files main() method. 
This eliminates the need for test suite files that have to call main on each individual test file.

## Why? Run all tests automatically from your build tool

Dart encourages test suite like files which call all your test files manually. This will automate that tedious task.

## Configuring

Add the dependency to your pubspec.yaml:

    dev_dependencies:
    - grinder_automated_test_task

Import it into your grinder.dart tasks file:

    import 'package:grinder_automated_test_task/grinder_automated_test_task.dart';

Create a task giving it a task name and any dependencies you want for the test task:

    defineTask('init', ...);
    addTask(createAutomatedTestTask('test', depends: ['init']));
    defineTask(...);

Add the test file to your .gitignore/.hgignore file:

    #Ignore testMain file produced by grinder_automated_test_task
    test/testMain.dart
    
## How it works

Generates a 'test/testMain.dart' file test main of all 'test/**/*Test.dart' and 'test/**/*_test.dart' test files


## Reporting issues

Please use the [issue tracker][issues].

[issues]: https://github.com/nicholastuck/grinder_automated_test_task/issues
