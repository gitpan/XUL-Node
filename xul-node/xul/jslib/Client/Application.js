
use("Client_Runner");
use("Client_ServerProxy");

Class("Client_Application");
Class_Singleton();

Client_Application.simulationMode = false;

_.init = function () {
	this.runner = Client_Runner.get();
	this.server = new Client_ServerProxy;
	this.runRequest();
}

// events ---------------------------------------------------------------------

_.fireEvent_Command = function (domEvent) {
	var source = domEvent.target;
	if (source.tagName == 'menuitem') {
		var realSource = source.parentNode.parentNode;
		if (realSource.tagName == 'menu') {
			this.fireEvent('Click', domEvent, {});
		} else {
			var selectedIndex;
			if (realSource.tagName == 'button') {
				var children = source.parentNode.childNodes;
				selectedIndex = children.length;
				while (selectedIndex--) if (children[selectedIndex] == source) break;
			} else { // a menulist
				selectedIndex = realSource.selectedIndex;
			}
			this.fireEvent(
				'Select',
				{'target': realSource},
				{'selectedIndex': selectedIndex}
			);
		}
	} else {
		this.fireEvent('Click', domEvent, {});
	}
}

_.fireEvent_Select = function (domEvent) {
	var source = domEvent.target;
	var selectedIndex = source.selectedIndex;
	if (selectedIndex == -1) return; // listbox: mozilla fires strange events
	this.fireEvent
		('Select', {'target': source}, {'selectedIndex': selectedIndex });
}

_.fireEvent_Pick = function (domEvent) {
	var source = window.document.getElementById(domEvent.targetId);
	this.fireEvent('Pick', {'target': source}, {'color': source.color });
}

_.fireEvent_Change = function (domEvent)
	{ this.fireEvent('Change', domEvent, {'value': domEvent.target.value}) }

// private --------------------------------------------------------------------

_.fireEvent = function (name, domEvent, params) {
	var source   = domEvent.target;
	var sourceId = source.id;
	if (!sourceId) return; // event could come from some unknown place
	var event = {
		'source' : sourceId,
		'name'   : name,
		'checked': source.getAttribute('checked')
	};
	var key; for (key in params) event[key] = params[key];
	this.runRequest(event);
}

_.runRequest = function (event) {
	if (Client_Application.simulationMode) return;
	window.status = "Loading UI...";
	var response  = event? this.server.event(event): this.server.boot();
	window.status = "Running UI...";
	this.runner.run(response);
	window.status = "Done.";
}



