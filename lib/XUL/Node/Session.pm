package XUL::Node::Session;

use strict;
use warnings;
use Carp;
use XUL::Node::Application;
use XUL::Node::ChangeManager;
use XUL::Node::EventManager;

# public ----------------------------------------------------------------------

sub new {
	my $class = shift;
	my $self = bless {
		change_manager  => XUL::Node::ChangeManager->new,
		event_manager   => XUL::Node::EventManager->new,
		start_time      => time,
	}, $class;
	$self->change_manager->event_manager($self->event_manager);
	return $self;
}

sub handle_boot {
	my ($self, $request) = @_;
	return $self->run_and_flush
		(XUL::Node::Application->get_constructor($request->{name}));
}

sub handle_event {
	my ($self, $request) = @_;
	my $event = $self->make_event($request);
	return $self->run_and_flush(sub { $self->fire_event($event) });
}

sub destroy {
	my $self = shift;
	$self->{change_manager}->destroy;
}

# private ---------------------------------------------------------------------

sub run_and_flush  { shift->change_manager->run_and_flush(pop) }
sub fire_event     { shift->event_manager->fire_event(pop) }
sub make_event     { shift->event_manager->make_event(@_) }
sub change_manager { shift->{change_manager} }
sub event_manager  { shift->{event_manager} }

1;