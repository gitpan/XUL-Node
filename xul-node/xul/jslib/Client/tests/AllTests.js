
Class("Client_tests_AllTests");

_.suite = function () {
	var suite = new Test_Suite("Client package");
	suite.addTestCase("Client_tests_ServerProxy");
	return suite;
}
