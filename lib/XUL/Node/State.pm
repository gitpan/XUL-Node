package XUL::Node::State;

use strict;
use warnings;
use Carp;

use constant {
	SEPERATOR      => chr(2),
	PART_SEPERATOR => chr(1),
};

# buffer is list of attribute key/value pairs set on state since last flush
# is_new is true if we have never been flushed before
# is_destroyed true after node has been destroyed
sub new { bless {buffer => [], is_new => 1, is_destroyed => 0}, shift }

sub flush {
	my $self = shift;
	my $out = $self->as_command;
	$self->set_old;
	$self->clear_buffer;
	return $out;
}

# command building ------------------------------------------------------------

sub as_command {
	my $self = shift;
	my $is_new       = $self->is_new;
	my $is_destroyed = $self->is_destroyed;
	return
		$is_new && $is_destroyed?
			'':
			$is_destroyed?
				$self->make_command_bye:
				$self->make_command_new. $self->get_buffer_as_commands;
}

sub make_command_new {
	my $self = shift;
	return '' unless $self->is_new;
	my $parent_id = $self->get_parent_id || 0;
	make_command($self->get_id, new => $self->get_tag, $parent_id);
}

sub make_command_bye {
	my $self = shift;
	my $parent_id = $self->get_parent_id || 0;
	make_command($self->get_id, 'bye');
}

sub make_command_set {
	my ($self, $key, $value) = @_;
	$value = '' unless defined $value;
	for ($value) {
		s/${\( SEPERATOR )}/_/g;
		s/${\( PART_SEPERATOR )}/_/g;
	}
	make_command($self->get_id, set => $key, $value);
}

# also used by tests to create oracle commands
sub make_command { join(PART_SEPERATOR, @_). SEPERATOR }

sub get_buffer_as_commands {
	my $self = shift;
	local $_;
	return join '', map { $self->make_command_set(@$_) } $self->get_buffer;
}

# accessors -------------------------------------------------------------------

sub get_id        { shift->{id}           }
sub get_tag       { shift->{tag}          }
sub is_new        { shift->{is_new}       }
sub get_parent_id { shift->{parent_id}    }
sub get_buffer    { @{shift->{buffer}}    }
sub is_destroyed  { shift->{is_destroyed} }

# modifiers -------------------------------------------------------------------

sub set_id        { shift->{id}           = pop             }
sub set_tag       { shift->{tag}          = lc pop          }
sub set_old       { shift->{is_new}       = 0               }
sub clear_buffer  { shift->{buffer}       = []              }
sub set_parent_id { shift->{parent_id}    = pop             }
sub set_destroyed { shift->{is_destroyed} = 1               }
sub set_attribute { push @{$_[0]->{buffer}}, [$_[1], $_[2]] }

1;
