
use("Client_ServerResponse");

Class("Client_ServerProxy");

_.init = function () {
	this.xml = new DOMParser();
	this.requestCount    = 0;
	this.applicationName = location.search.substr(1) || false;
	this.requestPrefix   = "xul";
	this.sessionId       = null;
}

_.boot =  function (applicationName) {
	this.applicationName = applicationName || this.applicationName;
	var event = {"type": "boot"};
	if (this.applicationName)
		event.name = this.applicationName;
	return this.request(event, 1);
}

_.event = function (event) {
	if (!this.sessionId) Throw("firing event with no session");
	event.type    = "event";
	event.session = this.sessionId;
	return this.request(event);
}

_.request = function (event, isBoot) {
	event.requestCount = ++this.requestCount;
	var payloadXML     = this.getPayloadAsXML(event);
	var rawResponse    = Util_Conduit.get().
		request(this.requestPrefix, payloadXML);
	if (isBoot) {
		this.sessionId = (rawResponse.split("\n"))[0];
		rawResponse    = rawResponse.replace(/.*\n/, '');
	}
	return new Client_ServerResponse(rawResponse);
}

_.getPayloadAsXML = function (event) {
	var root = this.xml.parseFromString
		('<?xml version="1.0" encoding="UTF-8"?><xul></xul>', "text/xml");
	var doc = root.documentElement;
	var key, value;
	for (key in event) {
		var element  = root.createElement(key);
		element.appendChild(root.createTextNode(event[key]));
		doc.appendChild(element);
	}
	return root;
}
