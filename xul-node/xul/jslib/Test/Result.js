
use("Test_Failure");
use("Test_AssertionFailedError");

Class("Test_Result");

_.init = function () {
	this.runCount = 0;
	this.errors   = new Array;
	this.failures = new Array;
}

_.run = function (test) {
	this.startTest(test);
	try {
		test.runBare();
	} catch (e) {
		if (e instanceof Test_AssertionFailedError)
			this.addFailure(test, e);
		else
			this.addError(test, e);
	}
	this.endTest(test);
}

_.setListener = function (listener) { this.listener = listener }
_.endTest     = function (test)     { this.listener.endTest(test) }

_.startTest = function (test) {
	this.runCount += test.countTestCases();
	this.listener.startTest(test);
}

_.addError = function (test, error) {
	var failure = new Test_Failure(test, error);
	this.errors = this.errors.concat(failure);
	this.listener.addError(failure);
}

_.addFailure =function (test, error) {
	var failure   = new Test_Failure(test, error);
	this.failures = this.failures.concat(failure);
	this.listener.addFailure(failure);
}
