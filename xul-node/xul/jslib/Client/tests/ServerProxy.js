
use ("Client_ServerProxy");

Class("Client_tests_ServerProxy", "Test_Case");

_.testBoot = function () {
	var proxy = new Client_ServerProxy;
	var response = proxy.boot("HelloWorld").getMessage().
		replace(/\x01/g, ".").replace(/\x02/g, "\n");
	this.assert(
		"boot1: " + response,
		response.indexOf("E2.new.window.0") != -1
	);
	this.assert(
		"boot2: " + response,
		response.indexOf("E1.new.label.E2.0") != -1
	);
	this.assert(
		"boot3: " + response,
		response.indexOf("E1.set.value.Hello World!") != -1
	);
}
