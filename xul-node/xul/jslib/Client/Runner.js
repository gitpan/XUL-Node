
Class("Client_Runner");
Class_Singleton();

_.init = function () { this.document = window.document }

_.run = function (response) {
	this.resetBuffers();

	var commands = response.getCommands();
	var command;
	for (command in commands)
		this.runCommand(commands[command]);

	var roots = this.newNodeRoots;
	var parentId;
	for (parentId in roots)
		this.getNode(parentId).appendChild(roots[parentId]);

	var lateCommands = this.lateCommands;
	for (command in lateCommands) {
		command = lateCommands[command];
		this.commandSetNode
			(command['nodeId'], command['arg1'], command['arg2']);
	}
}

// commands -------------------------------------------------------------------

_.runCommand = function (command) {
	var nodeId     = command['nodeId'];
	var methodName = command['methodName'];
	var arg1       = command['arg1'];
	var arg2       = command['arg2'];
	if (methodName == 'new')
		if (arg1 == 'window')
			this.commandNewWindow(nodeId);
		else
			this.commandNewElement(nodeId, arg1, arg2);
	else
		if (methodName == 'bye')
			this.commandByeElement(nodeId);
		else
			if (Client_Runner.lateAttributes[arg1])
				this.lateCommands.push(command);
			else
				this.commandSetNode(nodeId, arg1, arg2);
}

_.commandNewWindow = function (nodeId) {
	this.windowId = nodeId;
}

_.commandNewElement = function (nodeId, tagName, parentId) { try {
	var element = this.createElement(tagName, nodeId);
	this.newNodes[nodeId] = element;

	var parent = this.newNodes[parentId];
	if (parent)
		parent.appendChild(element);
	else
		this.newNodeRoots[parentId] = element;

	// onselect does not bubble
	if (tagName == 'listbox')
		element.setAttribute('onselect', 'window.onselect(event)');
	else if (tagName == 'colorpicker')
		element.setAttribute(
			'onselect',
			'Client_Application.get().fireEvent_Pick({"targetId":"' +
				element.id + '"})'
		);
} catch (e) {
	Throw(e,
		'Cannot create new node: [' + nodeId +
		', ' + tagName + ', ' + parentId + ']'
	);
}}

_.commandSetNode = function (nodeId, key, value) { try {
	var element = this.newNodes[nodeId];

	if (!element) element = this.getNode(nodeId);

	if (key == 'textNode') {
		element.appendChild(this.document.createTextNode(value));
		return;
	}
	if (Client_Runner.boleanAttributes[key]) {
		value = (value == 0 || value == '' || value == null)? false: true;
		if (!value)
			element.removeAttribute(key);
		else
			element.setAttribute(key, 'true');
		return;
	}
	if (Client_Runner.simpleMethodAttributes[key]) {
		if (element.tagName == 'window')
			window[key].apply(window);
		else
			element[key].apply(element);
		return;
	}
	if (Client_Runner.propertyAttributes[key]) {
		if (key == 'selectedIndex')
			element.setAttribute("suppressonselect", true);
		element[key] = value;
		if (key == 'selectedIndex')
			element.setAttribute("suppressonselect", false);
		return;
	}
	element.setAttribute(key, value);
} catch (e) {
	Throw(e,
		'Cannot do set on node: [' + nodeId + ', ' + key + ', ' + value + ']'
	);
}}

_.commandByeElement = function (nodeId) {
	var node = this.getNode(nodeId);
	node.parentNode.removeChild(node);
}

// private --------------------------------------------------------------------

_.getNode = function (nodeId) {
	var node = this._getNode(nodeId);
	if (!node) Throw("cannot find node by Id: " + nodeId);
	return node;
}

_._getNode = function (nodeId) {
	var node = this.windowId == nodeId?
		this.document.firstChild:
		this.document.getElementById(nodeId);
	return node;
}	

_.createElement = function (tagName, nodeId) {
	var element = tagName.match(/^html_/)?
		this.document.createElementNS(
			'http://www.w3.org/1999/xhtml',
			tagName.replace(/^html_/, '')
		):
		this.document.createElementNS(
			'http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul',
			tagName
		);
	element.id = nodeId;
	return element;
}

_.resetBuffers = function () {
	this.newNodeRoots = []; // top level parent nodes of those not yet added
	this.newNodes     = []; // nodes not yet added to document
	this.lateCommands = []; // commands to run at latest possible time
}

Client_Runner.boleanAttributes = {
	'disabled'     : true,
	'multiline'    : true,
	'readonly'     : true,
	'checked'      : true,
	'hidden'       : true,
	'default'      : true,
	'grippyhidden' : true
};
Client_Runner.propertyAttributes = {
	'selectedIndex': true
};
Client_Runner.lateAttributes = {
	'selectedIndex': true,
	'sizeToContent': true
};
Client_Runner.simpleMethodAttributes = {
	'sizeToContent': true
};

 