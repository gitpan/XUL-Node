
Class("Test_Case", "Test_Assert");

_.init           = function (name)   { this.name = name || "noname" }
_.run            = function (result) { result.run(this) }
_.countTestCases = function ()       { return 1 }
_.setUp          = function ()       {}
_.tearDown       = function ()       {}

_.runBare = function () {
	this.setUp();
	var runError = false;
	try { this.runTest() } catch (e) { runError = e }
	this.tearDown();
	if (runError) Throw(runError.description);
}

_.runTest = function () {
	var methodName = this.name;
	if (!methodName) Throw("Running test with no name");
	var method = eval("this." + methodName);
	method.call(this);
}

