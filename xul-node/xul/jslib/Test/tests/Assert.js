
Class("Test_tests_Assert", "Test_Case");

_.testAssertPass = function () {
	this.assert("true is true", true);
	this.assert("1 is true", 1);
}

_.testAssertFail = function () {
	try {
		this.assert("false is false", 0);
	} catch (e) {
		if (e instanceof Test_AssertionFailedError) return;
	}
	this.fail("false is false");
}

_.testAssertEquals = function () {
	this.assertEquals("foo is foo", "foo", "foo");
	this.assertEquals("123 is 123", 123, 123);
}
