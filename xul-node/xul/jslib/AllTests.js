
Class("AllTests");

_.suite = function () {
	var suite = new Test_Suite("NS6 jslib");
	suite.addTestSuite("Test_tests_AllTests");
	suite.addTestSuite("Util_tests_AllTests");
	suite.addTestSuite("Client_tests_AllTests");
	return suite;
}
