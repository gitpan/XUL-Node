
Class("Test_tests_AllTests");

_.suite = function () {
	var suite = new Test_Suite("Test package");
	suite.addTestCase("Test_tests_Assert");
	suite.addTestCase("Test_tests_Suite");
	return suite;
}
