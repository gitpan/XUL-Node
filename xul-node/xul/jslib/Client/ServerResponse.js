
Class("Client_ServerResponse");

Client_ServerResponse.wordSeperator = String.fromCharCode(1);
Client_ServerResponse.lineSeperator = String.fromCharCode(2);

_.init = function (response) {
	this.message  = response;
	this.commands = this.parseCommands();
	if (response.match(/^ERROR/)) Throw("Server side error. " + response);
//	this.dumpResponse();
}

_.parseCommands = function () {
	var outLines = [];
	if (this.message == 'null') return outLines;
	var inLines = this.message.split(this.$classObj.lineSeperator);
	var inLine;
	for (inLine in inLines) {
		inLine = inLines[inLine];
		if (!inLine.match(/\w/)) continue;
		var params  = inLine.split(this.$classObj.wordSeperator);
		outLines.push({
			'nodeId'    : params[0],
			'methodName': params[1],
			'arg1'      : params[2],
			'arg2'      : params[3],
			'arg3'      : params[4]
		});
	}
	return outLines;
}

_.dumpResponse = function () {
	var commands = this.getCommands();
	dumpln("* received response (" + commands.length + " lines):");
	var command;
	for (command in commands) {
		command = commands[command];
		dumpln(
			"   " + this.pad(command['nodeId'], 4) + '.' + command['methodName'] +
			'(' + command['arg1'] + ', ' + command['arg2'] + ")"
		);
	}
}

_.pad = function (input, length) {
	var inLength = input.length;
	if (inLength >= length) return input;
	padLength = length - inLength;
	var count;
	for (count = 0; count < padLength; count++) input = ' ' + input;
	return input;
}

_.getCommands = function () { return this.commands }
_.getMessage  = function () { return this.message  }

