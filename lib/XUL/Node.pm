package XUL::Node;

use strict;
use warnings;
use Carp;
use XUL::Node::Constants;

our $VERSION = '0.03';

my @XUL_ELEMENTS = qw(
	Window Box HBox VBox Label Button TextBox TabBox Tabs TabPanels Tab TabPanel
	Grid Columns Column Rows Row CheckBox Seperator Caption GroupBox MenuList
	MenuPopup MenuItem ListBox ListItem Splitter Deck Spacer HTML_Pre HTML_H1
	HTML_H2 HTML_H3 HTML_H4 HTML_A HTML_Div ColorPicker Description Image
	ListCols ListCol ListHeader ListHead Stack RadioGroup Radio Grippy
	ProgressMeter ArrowScrollBox ToolBox ToolBar ToolBarSeperator ToolBarButton
	MenuBar Menu MenuSeparator StatusBarPanel StatusBar
);

# creating --------------------------------------------------------------------

my %XUL_ELEMENTS = map { $_ => 1 } @XUL_ELEMENTS;

sub import {
	my $class   = shift;
	my $package = caller();
	no strict 'refs';
	# export factory methods for each xul element type
	foreach my $tag (@XUL_ELEMENTS) {
		*{"${package}::$tag"} = sub
			{ my $scalar_context = $class->new(tag => $tag, @_) };
	}
	# export the xul element constants
	foreach my $constant_name (@XUL::Node::Constants::EXPORT)
		{ *{"${package}::$constant_name"} = *{"$constant_name"} }
}

sub new {
	my ($class, @params) = @_;
	my $self = bless {attributes => {}, children => [], events => {}}, $class;
	while (my $param = shift @params) {
		if (UNIVERSAL::isa($param, __PACKAGE__))
			{ $self->add_child($param) }
		elsif ($param =~ /^[a-z]/)
			{ $self->set_attribute($param => shift @params) }
		elsif ($param =~ /^[A-Z]/)
			{ $self->attach($param => shift @params) }
		else
			{ croak "unrecognized param: [$param]" }
	}
	return $self;
}

# attribute handling ----------------------------------------------------------

sub attributes    { wantarray? %{shift->{attributes}}: shift->{attributes} }
sub get_attribute { shift->attributes->{pop()} }
sub set_attribute {shift->attributes->{pop()} = pop }
sub is_window     { shift->tag eq 'Window' }

sub AUTOLOAD {
	my $self = shift;
	my $key  = our $AUTOLOAD;
	return if $key =~ /DESTROY$/;
	$key =~ s/^.*:://;
	return $key =~ /^[a-z]/?
		@_ == 0?
			$self->get_attribute($key):
			$self->set_attribute($key, shift):
		$key =~ /^[A-Z]/?
			$self->add_child(__PACKAGE__->new(tag => $key, @_)):
			croak __PACKAGE__. "::AUTOLOAD cannot find message called [$key]";
}

# compositing -----------------------------------------------------------------

sub children    { wantarray? @{shift->{children}}: shift->{children} }
sub child_count { scalar @{shift->{children}} }
sub add_child   { push @{shift->{children}}, pop }

# event handling --------------------------------------------------------------

sub attach { shift->{events}->{pop()} = pop }

sub detach {
	my ($self, $name) = @_;
	my $listener = delete $self->{events}->{$name};
	croak "no listener to detach: $name" unless $listener;
}	

sub fire_event {
	my ($self, $event) = @_;
	my $listener = $self->{events}->{$event->name};
	return unless $listener;
	$listener->($event);
}

# destroying ------------------------------------------------------------------

# protected, used by sessions to free node memory
# event handlers could cause reference cycles, so we free them manually
sub destroy {
	my $self = shift;
	delete $self->{events};
	$_->destroy for $self->children;
}

# testing ---------------------------------------------------------------------

sub as_xml {
	my $self       = shift;
	my $level      = shift || 0;
	my $tag        = $self->tag;
	my $attributes = $self->attributes_as_xml;
	my $children   = $self->children_as_xml($level + 1);
	my $indent     = $self->get_indent($level);
	return
		qq[<$tag$attributes${\( $children? ">\n$children$indent</$tag": '/' )}>];
}

sub attributes_as_xml {
	my $self       = shift;
	my %attributes = $self->attributes;
	my $xml        = '';
	$xml .= qq[ $_="${\( $self->$_ )}"]
		for grep { $_ ne 'tag'} keys %attributes;
	return $xml;
}

sub children_as_xml {
	my $self   = shift;
	my $level  = shift || 0;
	my $indent = $self->get_indent($level);
	my $xml    = '';
	$xml .= qq[$indent${\( $_->as_xml($level) )}\n] for $self->children;
	return $xml;
}

sub get_indent { ' ' x (3 * pop) }

1;

=head1 NAME

XUL-Node - server-side XUL for Perl

=head1 SYNOPSIS

  use XUL::Node;

  # creating
  $window = Window(                            # window with a header,
     HTML_H1(textNode => 'a heading'),         # a label, and a button
     $label = Label(FILL, value => 'a label'),
     Button(label => 'a button'),
  );

  # attributes
  $label->value('a value');
  $label->style('color:red');
  print $label->flex;

  # compositing
  print $window->child_count;                  # prints 2
  $window->Label(value => 'another label');    # add a label to window
  $window->add_child(Label);                   # same but takes child as param
  $button = $window->children->[1];            # navigate the widget tree

  # events
  $window->Button(Click => sub { $label->value('clicked!') });
  $window->MenuList(
     MenuPopup(map { MenuItem(label => "item #$_", ) } 1..10),
     Select => sub { $label->value(shift->selectedIndex) },
  );


=head1 DESCRIPTION

XUL-Node is a rich user interface framework for server-based Perl
applications. It includes a server, a UI framework, and a Javascript XUL
client for the Firefox web browser. Perl applications run inside a POE
server, and are displayed in a remote web browser.

The goal is to provide Perl developers with the XUL/Javascript
development model, but with two small differences:

=over 4

=item *

Make it Perl friendly

=item *

Allow users to run the application on remote servers, so clients only
require Firefox, while the Perl code runs on the server

=back

XUL-Node works by splitting each widget into two: a server half, and a
client half. The server half sends DOM manipulation commands, and the
client half sends DOM events. A small Javascript client library takes
care of the communications.

The result is an application with a rich user interface, running in
Firefox with no special security permissions, built in 100% pure Perl.

=head1 DEVELOPER GUIDE

Programming in XUL-Node feels very much like working in a desktop UI
framework such as PerkTk or WxPerl. You create widgets, arrange them in a
composition tree, configure their attributes, and listen to their events.

Web development related concerns are pushed from user code into the
framework- no need to worry about HTTP, parameter processing, saving
state, and all those other things that make it so hard to develop a
high-quality web application.

=head2 Welcome to XUL

XUL is an XML-based User interface Language. XUL-Node exposes XUL to the
Perl developer. You need to know the XUL bindings to use XUL-Node.
Fortunately, these can be learned in minutes. For a XUL reference, see
XUL Planet (L<http://www.xulplanet.com/>).

=head2 Hello World

We start with the customary Hello World:

  package XUL::Node::Application::HelloWorld;
  use XUL::Node;
  use base 'XUL::Node::Application';

  sub start { Window(Label(value => 'Hello World!')) }

  1;

This is an application package, which creates a window with a label as
its single child.

=head2 Applications

To create an application:

=over 4

=item *

Subclass L<XUL::Node::Application>.

=item *

Name your application package under C<XUL::Node::Application>. E.g.
C<XUL::Node::Application::MyApp>.

=item *

Implement one template method, C<start()>.

=back

In C<start()> you must create at least one window, if you want the UI to
show. The method is run once per application per session. This is where
you create widgets and attach event listeners.

XUL-Node comes with 14 example applications in the
C<XUL::Node::Application> namespace.

Applications are launched by starting the server and pointing Firefox at
a URL. You start the server with the command:

  xul-node-server

Run it with the option C<--help> for usage info. This will start a
XUL-Node server on the default server root and port you defined when
running the C<Makefile.PL> script.

You can then run the application from Firefox, by constructing a URL so:

  http://SERVER:PORT/start.xul?APPLICATION#DEBUG

  SERVER       server name
  PORT         HTTP port configured when starting server
  APPLICATION  application name, if none given, runs HelloWorld
  DEBUG        0 or 1, default is 0, turn on client debug info

The application name is the last part of its package name. So the package
C<XUL::Node::Application::PeriodicTable> can be run using the application
name C<PeriodicTable>. All applications must exist under C<@INC>, under
the namespace C<XUL::Node::Application>.

So for example, to run the splitter example on a locally installed server,
you would browse to:

  http://localhost:8077/start.xul?SplitterExample#1

The installation also creates an index page, providing links to all
examples. By default it will be available at:

  http://localhost:8077

=head2 Widgets

To create a UI, you will want your C<start()> method to create a window
with some widgets in it. Widgets are created by calling a function or
method named after their tag:

  $button = Button;                           # orphan button with no label
  $box->Button;                               # another, but added to a box
  $widget = XUL::Node->new(tag_name => $tag); # using dynamic tag

After creating a widget, you must add it to a parent. The widget will
show when there is a containment path between it and a window. There are
3 ways to parent widgets:

  $parent->add_child($button);                # using add_child
  $parent->Button(label => 'hi!');            # create and add in one shot
  Box(style => 'color:red', $label);          # add in parent constructor

Widgets have attributes. These can be set in the constructor, or via
get/set methods:

  $button->value('a button');
  print $button->value;                       # prints 'a button'

You can configure all attributes, event handlers, and children of a
widget, in the constructor. There are also constants for commonly used
attributes. This allows for some nice code:

  Window(SIZE_TO_CONTENT,
     Grid(FLEX,
        Columns(Column(FLEX), Column(FLEX)),
        Rows(
           Row(
              Button(label => "cell 1"),
              Button(label => "cell 2"),
           ),
           Row(
              Button(label => "cell 3"),
              Button(label => "cell 4"),
           ),
        ),
     ),
  );

Check out the XUL references (L<http://www.xulplanet.com>) for
an explanation of available widget attributes.

=head2 Events

Widgets receive events from their client halves, and pass them on to
attached listeners in the application. You attach a listener to a widget
so:

  # listening to existing widget
  $button->attach(Change => sub { print 'clicked!' });

  # listening to widget in constructor
  TextBox(Change => sub { print shift->value });

You attach events by providing an event name and a listener. Possible
event names are C<Click>, C<Change>, C<Select>, and C<Pick>. Different
widgets fire different events. These are listed in L<XUL::Node::Event>.

Listener are callbacks that receive a single argument: the event object
(L<XUL::Node::Event>). You can query this object for information about the
event: C<name>, C<source>, and depending on the event type: C<checked>,
C<value>, C<color>, and C<selectedIndex>.

Here is an example of listening to the C<Select> event of a list box:

  Window(
     VBox(FILL,
        $label = Label(value => 'select item from list'),
        ListBox(FILL, selectedIndex => 2,
           (map { ListItem(label => "item #$_") } 1..10),
           Select => sub {
              $label->value
                 ("selected item #${\( shift->selectedIndex + 1 )}");
           },
        ),
     ),
  );

=head2 Images and Other Resources

When XUL-Node is installed, a server root directory is created at a
user-specified location. By default it is C<C:\Perl\xul-node> on
C<Win32>, and C</usr/local/xul-node> elsewhere.

You place images and other resources you want to make available via HTTP
under the directory:

  SERVER_ROOT/xul

The example images are installed under:

  SERVER_ROOT/xul/images

You can access them from your code by pointing at the file:

  Button(ORIENT_VERTICAL,
     label => 'a button',
     image => 'images/button_image.png',
  );

Any format Firefox supports should work.

=head2 XUL-Node API vs. the Javascript XUL API

The XUL-Node API is different in the following ways:

=over 4

=item *

Booleans are Perl booleans.

=item *

There is no difference between attributes, properties, and methods. They
are all attributes.

=item *

There exist constants for common attribute key/value pairs. See
C<XUL::Node::Constants>.

=back

=head1 INTERNALS

XUL-Node acts as a very thin layer between your Perl application, and the
Firefox web browser. All it does is expose the XUL API in Perl, and
provide the server so you can actually use it. Thus it is very small.

It does this using the Half Object pattern
(L<http://c2.com/cgi/wiki?HalfObjectPlusProtocol>). XUL elements have a
client half (the DOM element in the document), but also a server half,
represented by a C<XUL::Node> object. User code calls methods on the
server half, and listens for events. The server half forwards them to the
client, which runs them on the displayed DOM document.

=head2 The Wire Protocol

Communications is done through HTTP POST, with an XML message body in the
request describing the event, and a response composed of a list of DOM
manipulation commands.

Here is a sample request, showing a boot request for the C<HelloWorld>
application:

  <xul>
     <type>boot</type>
     <name>HelloWorld</name>
  </xul>

Here is a request describing a selection event in a C<MenuList>:

  <xul>
     <type>event</type>
     <name>Select</name>
     <source>E2</source>
     <session>ociZa4lBESk+9ptkVfr5qw</session>
     <selectedIndex>3</selectedIndex>
  </xul>

Here is the response to the C<HelloWorld> boot request. The 1st line of
the boot response is the session ID created by the server.

  Li6iZ6soj4JqwnkDUmmXsw
  E2.new(window, 0)
  E2.set(sizeToContent, 1)
  E1.new(label, E2)
  E1.set(value, Hello World!)

Each command in a response is built of the widget ID, the
attribute/property/method name, and an argument list.

=head2 The Server

The server uses C<POE::Component::HTTPServer>. It configures a handler
that forwards requests to the session manager. The session manager
creates or retrieves the session object, and gives it the request. The
session runs user code, and collects any changes done by user code to the
DOM tree. These are sent to the client.

Aspects are used by C<XUL::Node::ChangeManager> to listen to DOM state
changes, and record them for passing on to the client.

The C<XUL::Node::EventManager> keeps a weak list of all widgets, so they
can be forwarded events, as they arrive from the client.

A time-to-live timer is run using C<POE>, so that sessions will expire
after 10 minutes of inactivity.

=head2 The Client

The client is a small Javascript library which handles:

=over 4

=item *

Client/server communications, using Firefox C<XMLHTTPRequest>.

=item *

Running commands as they are received from the server.

=item *

Unifying attributes/properties/methods, so they all seem like attributes
to the XUL-Node developer.

=back

=head1 SUPPORTED WIDGETS

  Box, HBox, VBox, Label, Button, TextBox, TabBox, Grid, CheckBox,
  GroupBox, MenuList, ListBox, Splitter, Deck, Spacer, HTML_Pre,
  HTML_H1-4, HTML_A, HTML_Div, ColorPicker, Description, Image, Stack,
  Radio, ProgressMeter, ArrowScrollBox, ToolBox, ToolBar,
  ToolBarSeperator, MenuBar, Menu, StatusBar.

=head1 SUPPORTED TAGS

  Window, Box, HBox, VBox, Label, Button, TextBox, TabBox, Tabs,
  TabPanels, Tab, TabPanel Grid, Columns, Column, Rows, Row, CheckBox,
  Seperator, Caption, GroupBox, MenuList MenuPopup, MenuItem, ListBox,
  ListItem, Splitter, Deck, Spacer, HTML_Pre, HTML_H1 HTML_H2, HTML_H3,
  HTML_H4, HTML_A, HTML_Div, ColorPicker, Description, Image ListCols,
  ListCol, ListHeader, ListHead, Stack, RadioGroup, Radio, Grippy
  ProgressMeter, ArrowScrollBox, ToolBox, ToolBar, ToolBarSeperator,
  ToolBarButton MenuBar, Menu, MenuSeparator, StatusBarPanel, StatusBar.

=head1 LIMITATIONS

=over 4

=item *

Some widgets are not supported yet: tree, popup, and multiple windows

=item *

Some widget features are not supported yet:

  * multiple selections
  * node disposal
  * color picker will not fire events if type is set to button
  * equalsize attribute will not work
  * menus with no popups may not show

=back

See the TODO file included in the distribution for more information.

=head1 SEE ALSO

L<XUL::Node::Event> presents the list of all possible events.

L<http://www.xulplanet.com> has a good XUL reference.

L<http://www.mozilla.org/products/firefox/> is the browser home page.

=head1 BUGS

None known so far. If you find any bugs or oddities, please do inform the
author.

=head1 AUTHOR

Ran Eilam <eilara@cpan.org>

=head1 COPYRIGHT

Copyright 2003-2004 Ran Eilam. All rights reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
