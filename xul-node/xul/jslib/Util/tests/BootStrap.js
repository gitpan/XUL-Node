
Class("Util_tests_BootStrap", "Test_Case");

_.testInheritance = function () {

	var p1 = new Person("foo");
	this.assertEquals("Person 1 name"      , "foo"              ,p1.getName());
	this.assertEquals("Person 1 asString"  , "foo"              ,p1.asString());

	var p2 = new Person("bar");
	this.assertEquals("Person 2 name"      , "bar"              , p2.getName());
	this.assertEquals("Person 2 asString"  , "bar"              , p2.asString());


	var e1 = new Employee("baz");
	e1.setId(1234);
	this.assertEquals("Employee 1 name"    , "baz"              , e1.getName());
	this.assertEquals("Employee 1 id"      , 1234               , e1.getId());
	this.assertEquals("Employee 1 asString", "baz:1234"         , e1.asString());

	var e2 = new Employee("zab");
	e2.setId(4321);
	this.assertEquals("Employee 2 name"    , "zab"              , e2.getName());
	this.assertEquals("Employee 2 id"      , 4321               , e2.getId());
	this.assertEquals("Employee 3 asString", "zab:4321"         , e2.asString());


	var m1 = new Manager;
	m1.setName("john");
	m1.setId(5678);
	m1.setTitle("boss");
	this.assertEquals("Manager 1 name"     , "*john"            , m1.getName());
	this.assertEquals("Manager 1 id"       , 5678               , m1.getId());
	this.assertEquals("Manager 1 title"    , "boss"             , m1.getTitle());
	this.assertEquals("Manager 1 asString" , "*john:5678:boss"  , m1.asString());

	var m2 = new Manager;
	m2.setName("don");
	m2.setId(8765);
	m2.setTitle("manager");
	this.assertEquals("Manager 2 name"     , "*don"             , m2.getName());
	this.assertEquals("Manager 2 id"       , 8765               , m2.getId());
	this.assertEquals("Manager 2 title"    , "manager"          , m2.getTitle());
	this.assertEquals("Manager 2 asString" , "*don:8765:manager", m2.asString());

}

_.testClassName = function () {
	var p = new Person;
	var e = new Employee;
	var m = new Manager;
	this.assertEquals("Person"  , "Person"  , p.$className);
	this.assertEquals("Employee", "Employee", e.$className);
	this.assertEquals("Manager" , "Manager" , m.$className);
}

// ----------------------------------------------------------------------------

Class("Person");

_.init     = function (name)  { this.setName(name) }
_.getName  = function ()      { return this.name }
_.setName  = function (name)  { this.name = name }
_.asString = function ()      { return this.getName() }


Class("Employee", "Person");

_.getId    = function ()      { return this.id }
_.setId    = function (id)    { this.id = id }
_.asString = function ()      { return this.Person_asString() + ":" + this.getId() }


Class("Manager", "Employee");

_.getName  = function ()      { return "*" + this.name }
_.getTitle = function ()      { return this.title }
_.setTitle = function (title) { this.title = title }
_.asString = function ()      { return this.Employee_asString() + ":" + this.getTitle() }


use("Manager"); // will use employee, which will use Person

