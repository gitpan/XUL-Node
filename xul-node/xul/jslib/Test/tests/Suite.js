
Class("Test_tests_Suite", "Test_Case");

_.testGetTestMethods = function () {
	var suite = new Test_Suite("SomeTestSuite");
	var base  = new SomeBase();
	var child = new SomeObject();
	this.assertEquals
		("base test method", "testMethod2", suite.getTestMethods(base));
	this.assertEquals(
		"child test method",
		"testMethod2,testMethod3",
		suite.getTestMethods(child)
	);
}


Class("SomeBase");

_.init        = function () { this.someProperty1 = "foo" }
_.method1     = function () {}
_.testMethod2 = function () {}


Class("SomeObject", "SomeBase");

_.init = function () {
	this.someProperty2 = "bar";
	this.SomeBase_init();
}

_.testMethod2 = function () {}
_.testMethod3 = function () {}
_.method4     = function () {}

use("SomeObject");
