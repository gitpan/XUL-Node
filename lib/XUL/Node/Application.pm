package XUL::Node::Application;

use strict;
use warnings;
use Carp;

use constant {
	DEFAULT_NAME => 'HelloWorld',
	EXEC_PACKAGE => 'XUL::Node::Application',
};

sub get_constructor {
	my $self = shift;
	my $package = application_to_package(shift);
	runtime_use($package);
	return sub { $package->new->start };
}

sub new { bless {}, shift }

sub application_to_package {
	my $name = pop || DEFAULT_NAME;
	# remove following line- get big security hole
	croak "illegal name: [$name]" unless $name =~ /^[A-Z](?:\w*::)*\w+$/;
	$name = EXEC_PACKAGE. "::$name";
}

# private ---------------------------------------------------------------------

sub runtime_use {
	my $package = pop;
	eval "use $package";
	croak "cannot use: [$package]: $@" if $@;
}

# template methods ------------------------------------------------------------

sub start { croak "must be implemented in subclass" }

1;

=head1 NAME

XUL::Node::Application - base class for XUL-Node applications

=head1 SYNOPSYS

  # subclassing to create your own application
  package XUL::Node::Application::MyApp;
  use base 'XUL::Node::Application';
  sub start { Window(Label(value => 'Welcome to MyApp')) }

  # running the application from some handler in a server
  use XUL::Node::Application;
  XUL::Node::Application->get_constructor('MyApp')->();

  # Firefox URL
  http://SERVER:PORT/start.xul?MyApp

=head1 DESCRIPTION

To create a XUL-Node application, subclass from this class and provide
one template method: C<start()>. It will be called when the application
is started.

You can get a callback for running the application by calling the class
method C<get_constructor()>, which returns a C<CODE> ref that can be run
to start the application. This is how the session starts applications.

=cut
