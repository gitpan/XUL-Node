use("Test_Result");
use("Test_Suite");

Class("Test_Runner");

_.start = function (testName) {
	var suite  = this.getTest(testName);
	var result = this.doRun(suite);
	return result;
}

_.doRun = function (suite) {
	var result = new Test_Result;
	result.setListener(this);
	var startTime = (new Date).getTime().toString();
	suite.run(result);
	var endTime = (new Date).getTime().toString();
	var runTime = endTime-startTime;
	this.print("Completed " + result.runCount + " tests in " + runTime + " ms");
	this.printReport(result);
}

_.printReport = function (result) {
	var errorCount   = result.errors.length;
	var failureCount = result.failures.length;
	var color = (errorCount == 0 && failureCount == 0)? "green": "red";
	this.print(
		'Completed tests, error count = ' + errorCount +
		", failure count = " + failureCount + "\n"
	);
}

_.startTest = function (test)
	{ this.print(test.$className.replace(/_tests_/,"_") + "." + test.name) }

_.endTest = function (test) {}

_.addError = function (failure) { this.print(
	"Error in " + failure.test.name +
	", error:\n" + failure.error.description + "\n"
)}

_.addFailure = function (failure) { this.print(
	"Failure in " + failure.test.name +
	", failure:\n" + failure.error.description + "\n"
)}

_.print = function (message) { dumpln(message) }

_.getTest = function (testName) {
	use(testName);
	var suiteMethod = eval(testName + ".prototype.suite");
	if (!suiteMethod) return new Test_Suite(testName, 1);
	var result;
	try { result = suiteMethod.call() }
		catch (e) { Throw(e, "Calling suiteMethod on: " +  testName) }
	return result;
}
