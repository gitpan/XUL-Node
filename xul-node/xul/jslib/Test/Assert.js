
use("Test_AssertionFailedError");

Class("Test_Assert");

_.assert = function (message, condition) {
	if (arguments.length > 2)
		this.error("Too many arguments for assertEquals, " + message);
	if (!condition) this.fail(message);
}

_.assertEquals = function (message, expected, actual) {
	if (arguments.length < 3)
		this.error("Missing arguments for assertEquals, " + message);
	if (expected != actual)
		this.fail(message + ", expected:[" + expected + "] but was:[" + actual + "]");
}

_.fail  = function (message) { throw new Test_AssertionFailedError(message) }
_.error = function (message) { Throw(message) }
