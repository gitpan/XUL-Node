
/*

Essential stuff for XUL-Node

	* error handling
	* global events
	* global utility functions
	* javascript OO support
	* debug support
	* client server communications

*/

// sniffing -------------------------------------------------------------------

var VERSION = {
	"NS6up": navigator.userAgent.indexOf("Gecko")  != -1,
	"IE6up": navigator.userAgent.indexOf("MSIE 6") != -1
};

// global events --------------------------------------------------------------

var Class_LAST_ERROR = {'message': ''};

window.onerror = function ()
	{ if (Class_LAST_ERROR) dumpln(Class_LAST_ERROR.message) }

// error handling -------------------------------------------------------------

function Throw(a, b) {
	var message       = b? (a.message || a.description) + "\n" + b: a;
	var exception     = b? a: new Error;
	exception.message = exception.description = message;
	Class_LAST_ERROR  = exception;
	throw exception;
}

// global utilities -----------------------------------------------------------

function isDefined (value) { return value != undefined    }

function argsAsArray (args) {
	var results = [];
	for (var i in args) results.push(args[i]);
	return results;
}

function trim (s) {
	if (!s) return "";
	return s.replace(/^\s+/, "").replace(/\s+$/, "");
}

function dumpln (message) { dump(message + "\n") }

function use (className) { Class_Use(className) }

// OO support -----------------------------------------------------------------

$ForPrototype = false;
Class_Classes = {};

function Class (className, parentClassName) {
	Class_CheckClassName(className);
	if (parentClassName) {
		Class_CheckClassName(parentClassName);
		use(parentClassName);
	}
	var classObj = eval(
		className + " = function () {" +
			"if (!this.init) Throw('Class not used: " + className + "');" +
			"if ($ForPrototype) return;" +
			"this.init.apply(this, arguments);" +
		"}"
	);
	classObj.className       = className;
	Class_Classes[className] = classObj;
	if (parentClassName) classObj.parentClassName = parentClassName;
	_ = classObj.prototype;
	_.$classObj = classObj;
}

function Class_Singleton () {
	var classObj = _.$classObj;
	var singleton;
	classObj.get = function () {
		if (singleton) return singleton;
		singleton = new classObj;
		return singleton;
	};
}

function Class_Use (className) { try {
	var classObj = Class_Classes[className];
	if (!classObj) Util_Conduit.get().use(className);
	classObj = Class_Classes[className];
	if (!classObj) Throw("Class not declared before use: " + className);
	if (classObj.isUsed) return;

	var proto = classObj.prototype;
	var methodNames = Class_getMethodNames(proto);
	var i; for (i in methodNames) {
		var methodName      = methodNames[i];
		var method          = proto[methodName];
		var wrapped         = Class_wrapMethod(className, methodName, method);
		wrapped.$methodName = methodName;
		proto[methodName]   = wrapped;
	}

	var parentClassName = classObj.parentClassName;
	if (parentClassName) {
		var parentClassObj  = Class_Classes[parentClassName];
		if (!parentClassObj) Throw(
			"Base class not declared before inheritance: "
			+ className + ":" + parentClassName
		);
		if (!parentClassObj.isUsed) Throw(
			"Base class not used before inheritance: "
			+ className + ":" + parentClassName
		);
		$ForPrototype = true;
		var parentInstance = new parentClassObj;
		$ForPrototype = false;
		var i; for (i in methodNames) {
			var methodName   = methodNames[i];
			var parentMethod = parentInstance[methodName];
			var childMethod  = proto[methodName];
			if (parentMethod) {
				parentInstance[parentClassName + "_" + methodName] =
					parentInstance[methodName];
			}
			parentInstance[methodName] = childMethod;
		}
		classObj.prototype = parentInstance;
	}
	proto = classObj.prototype;
	if (!proto.init) proto.init = function () {};
	proto.$className = className;
	proto.$classObj  = classObj;
	classObj.isUsed  = true;
} catch (e) { Throw(e, "Using: " + className) }}

function Class_wrapMethod (className, methodName, method) {
	return !Util_Debug.get().getEnabled()?
		method:
		function () { try {

			Class_PreHandler(this, className, methodName, arguments);
			var returnValue = method.apply(this, arguments);
			Class_PostHandler(this, className, methodName, returnValue);
			return returnValue;

		} catch (_e) { Throw(_e,
			"* " + className + ":" + methodName + "(" + this.$className + ")"
		)}}
}

function Class_getMethodNames (o) {
	var methodNames = [];
	for (methodName in o)
		if (typeof o[methodName]  == "function" && !methodName.match(/^\$/))
			methodNames.push(methodName);
	return methodNames;
}

function Class_asString (o, verbose) {
	var result = "";
	var p; for (p in o) result += p + (verbose? ":" + o[p]: "");
	return result;
}

function Class_CheckClassName (className) {
	if (className.match(/\s/))
		Throw("Not a legal class name: [" + className + "]");
}

function Class_PreHandler (object, className, methodName, arguments) {
	return;
	if (methodName.match(/Min/))
		dumpln(
			className + ":" + methodName + "(" + object.$className + ") : " +
			argsAsArray(arguments).join(",")
		);
}

function Class_PostHandler (object, className, methodName, returnValue) {
	return;
	if (methodName.match(/Min/))
		dumpln(
			className + ":" + methodName + "(" + object.$className + ") : " +
			returnValue
		);
}

// debug support --------------------------------------------------------------

Class("Util_Debug");
Class_Singleton();

_.init       = function ()        { this.setEnabled(false) }
_.getEnabled = function ()        { return this.isEnabled }
_.setEnabled = function (value)   { this.isEnabled = value }
_.dumpBare   = function (message) { dump(message + "\n") }

use("Util_Debug");

// client server communications -----------------------------------------------

Class("Util_Conduit");
Class_Singleton();

_.init = function () {
	var hash = location.hash;
	Util_Debug.get().setEnabled(
		Util_Debug.get().getEnabled()? true:
		hash.substr(1) == 1? true: false
	);
	var pathname   = location.pathname.replace(/\/[^\/]+$/, "");
	var port       = location.port;
	port           = port? ':' + port: '';
	this.serverURL = 'http://'+location.hostname+port+pathname+"/";
	this.xmlHTTP   = (VERSION.IE6up)?
		new ActiveXObject("Microsoft.XMLHTTP"):
		new XMLHttpRequest;
}

_.request = function (request, payloadXML) { try {
	var xmlHTTP = this.xmlHTTP;
	xmlHTTP.overrideMimeType("text/xml");
	xmlHTTP.open("POST", this.serverURL + request, false);

	try { xmlHTTP.send(payloadXML || null) }
		catch (e) { Throw(e, "No response from server") }

	var response = new String(xmlHTTP.responseText);
	if (xmlHTTP.status != "200") Throw(
		"Cannot send request: " + xmlHTTP.statusText + "\n" +
		xmlHTTP.responseText
	);
	return response;
} catch (e) { Throw(e,
	"While requesting url: " + this.serverURL + ", request: " + request
)}}

_.use = function (className) { try {
	if (VERSION.NS6up)
		Throw("Cannot load classes in NS6up [" + className + "]");
	window.status = "Loading " + className + "...";
	var fileName = className.replace(
		/^Widget_/,
		"Widget_" + (VERSION.NS6up? "NS6": "IE6") + "_"
	);
	var libDir = "jslib/";
	var classText;
	try { classText = this.request(
		libDir + fileName.replace(/_/g, "/") + ".js"
	) } catch (e) { Throw(e, "Requesting class from server") }
	try { eval(classText.toString()) }
		catch(e) { Throw(e, "Evaling class text") }
	window.status = "Loaded " + className;
} catch (e) { Throw(e, "Importing: " + className) }}

use("Util_Conduit");
Util_Conduit.get();
