package XUL::Node::EventManager;

use strict;
use warnings;
use Carp;
use Scalar::Util qw(weaken);
use XUL::Node::Event;

sub new { bless {nodes => {}}, shift }

sub make_event {
	my ($self, $request) = @_;
	my $id = $request->{source};
	croak "cannot make event with no source" unless $id;
	$request->{source} = $self->get_node($id);
	croak "node with id [$id] not found" unless $request->{source};
	return XUL::Node::Event->make_event($request);
}

sub fire_event {
	my ($self, $event) = @_;
	$event->source->fire_event($event);
}

sub register_node {
	my ($self, $id, $node) = @_;
	my $nodes = $self->{nodes};
	$nodes->{$id} = $node;
	weaken $nodes->{$id};
}

# TODO: cleanup dangling weak ref now and then
sub get_node { shift->{nodes}->{pop()} }

1;

