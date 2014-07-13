library grinder_automated_test_task.exampleTests.shouldNotRunThis;

import 'package:unittest/unittest.dart';

main() {

  test("test that should not be added to main because file does not end in _test.dart or Test.dart", () {
    fail("shouldn't have run this test");
  });

}
