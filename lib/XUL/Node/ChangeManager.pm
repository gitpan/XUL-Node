package XUL::Node::ChangeManager;

use strict;
use warnings;
use Carp;
use Aspect;
use XUL::Node;
use XUL::Node::State;

# creating --------------------------------------------------------------------

sub new { bless {windows => [], next_node_id => 0}, shift }

# public interface for sessions -----------------------------------------------

sub run_and_flush {
	my ($self, $code) = @_;
	$code->();
	return join '', map { $self->flush_node($_) } @{$self->windows};
}

sub destroy {
	my $self = shift;
	$_->destroy for @{$self->{windows}};
	delete $self->{windows};
}

# advice ----------------------------------------------------------------------

my $Self_Flow = cflow source => __PACKAGE__.'::run_and_flush';

# when node changed register change on state
# if it has no state, give it one, give it an id, register the node, and
# register the node as a window if node is_window
after {
	my $context = shift;
	my $self    = $context->source->self;
	my $node    = $context->self;
	my $key     = $context->params->[1];
	my $value   = $context->params->[2];
	my $state   = $self->node_state($node);

	unless ($state) {
		push @{$self->windows}, $node if $node->is_window;
		$state = XUL::Node::State->new;
		my $id = 'E'. ++$self->{next_node_id};
		$state->set_id($id);
		$self->node_state($node, $state);
		$self->event_manager->register_node($id, $node)
			if $self->event_manager;
	}

	if ($key eq 'tag') { $state->set_tag($value) }
	else               { $state->set_attribute($key, $value) }

} call 'XUL::Node::set_attribute' & $Self_Flow;

# when node added, set parent node state id on child node state
after {
	my $context = shift;
	my $self    = $context->source->self;
	my $parent  = $context->self;
	my $child   = $context->params->[1];

	$self->node_state($child)->set_parent_id
		($self->node_state($parent)->get_id);

} call 'XUL::Node::add_child' & $Self_Flow;

# private ---------------------------------------------------------------------

sub flush_node {
	my ($self, $node) = @_;
	my $out = $self->node_state($node)->flush;
	$out .= $self->flush_node($_) for $node->children;
	return $out;
}

sub node_state {
	my ($self, $node, $state) = @_;
	return $node->{state} unless $state;
	$node->{state} = $state;
}

sub event_manager {
	my ($self, $event_manager) = @_;
	return $self->{event_manager} unless $event_manager;
	$self->{event_manager} = $event_manager;
}

# testing ---------------------------------------------------------------------

sub windows { shift->{windows} }

1;

