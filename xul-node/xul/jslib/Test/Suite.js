
use("Test_Case");

Class("Test_Suite");

_.init = function (thing, wrap) {
	this.tests = new Array();
	if (!wrap) {
		this.name = thing;
		return;
	}
	var testName = thing;
	use(testName);
	var test = eval("new " + testName);
	if (!(test instanceof Test_Case)) Throw("Not a Test_Case:" + testName);
	var testMethods = this.getTestMethods(test);
	if (!testMethods.length) Throw("No test methods in test:" + testName);
	var i; for (i in testMethods) {
		this.addTestMethod(testName, testMethods[i]);
	}
}

_.addTestMethod = function (testName, methodName) {
	var test; try {
		test = eval("new " + testName);
		test.name = methodName;
	} catch (e) { Throw(e,
		"Creating test: " + testName + " on method: " + methodName
	)}
	this.tests = this.tests.concat(test);
}

_.addTestCase = function (testName) {
	this.tests = this.tests.concat(new Test_Suite(testName, 1));
}

_.addTestSuite = function (suiteName) {
	use(suiteName);
	var suite = eval("new " + suiteName);
	this.tests = this.tests.concat(suite.suite());
}

_.run = function (result)
	{ var i; for (i in this.tests) this.tests[i].run(result) }

_.countTestCases = function () {
	var testCount = 0;
	var i; for (i in this.tests) testCount += this.tests[i].countTestsCases();
}

_.getTestMethods = function (test) {
	var result = new Array();
	var key; for (key in test) {
		var method = test[key];
		if (!(method instanceof Function)) continue;
		if (key.match("^test")) result = result.concat(key);
	}
	return result.sort();
}


