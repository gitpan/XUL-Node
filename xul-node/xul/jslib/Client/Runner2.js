
Class("Client_Runner");
Class_Singleton();

_.init =  function () {
	this.document     = window.document;
	this.newNodes     = {}; // nodes to add after their child has been added
	this.lateCommands = []; // commands to run at latest possible time
}

_.run = function (response) {
	var commands = response.getCommands();
	var command;
	for (command in commands)
		this.runCommand(commands[command]);
	for (command in this.lateCommands) {
		command = this.lateCommands[command];
		this.commandSetNode
			(command['nodeId'], command['arg1'], command['arg2']);
	}
	this.lateCommands = [];
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
		if (Client_Runner.lateAttributes[arg1])
			this.lateCommands.push(command);
		else
			this.commandSetNode(nodeId, arg1, arg2);
}

_.commandNewWindow = function (nodeId) {
	this.windowId = nodeId;
}

_.commandNewElement = function (nodeId, tagName, parentId) { try {
	var element;
	if (tagName.match(/^html_/)) {
		tagName = tagName.replace(/^html_/, '');
		element = this.document.createElementNS
			('http://www.w3.org/1999/xhtml', tagName);
	} else {
		element = this.document.createElementNS(
			'http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul',
			tagName
		);
	}
	element.id = nodeId;

	// hack: mozilla will not draw items in menulist if menupopup is
	// added to menulist AFTER the menulist has been added to its parent.
	// ditto for menu
	if (tagName == 'menulist' || tagName == 'menu') {
		element.parentId = parentId;
		this.newNodes[nodeId] = element;
	} else if (tagName == 'menupopup' && !this.isNodeInDocument(parentId)) {
		var parent = this.newNodes[parentId];
		var grandParent = this.getNode(parent.parentId);
		parent.appendChild(element);
		grandParent.appendChild(parent);
		parent.removeAttribute(parentId);
		delete this.newNodes[parentId];
	} else {
		// the normal case
		var parent = this.getNode(parentId);
		parent.appendChild(element);
		// onselect does not bubble
		if (tagName == 'listbox')
			element.setAttribute('onselect', 'window.onselect(event)');
		else if (tagName == 'colorpicker')
			element.setAttribute('onselect',
				'Client_Application.get().fireEvent_Pick({"targetId":"' +
				element.id + '"})'
			);
	}
} catch (e) {
	Throw(e,
		'Cannot create new node: [' + nodeId +
		', ' + tagName + ', ' + parentId + ']'
	);
}}

_.commandSetNode = function (nodeId, key, value) { try {
	var element =
			this.newNodes[nodeId]? this.newNodes[nodeId]: this.getNode(nodeId);
	if (!element) Throw('Cannot find node on parent: [' + nodeId + ']');

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

// private --------------------------------------------------------------------

_.isNodeInDocument = function (nodeId)
	{ return this._getNode(nodeId)? true: false }

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

 