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
sub new { bless {buffer => [], is_new => 1}, shift }

sub flush {
	my $self = shift;
	my $out = $self->as_command;
	$self->set_old;
	$self->clear_buffer;
	return $out;
}

sub as_command {
	my $self = shift;
	return
		($self->is_new? $self->make_command_new: '').
		join '', map { $self->make_command_set(@$_) } $self->get_buffer;
}

sub make_command_new {
	my $self = shift;
	my $parent_id = $self->get_parent_id || 0;
	make_command($self->get_id, new => $self->get_tag, $parent_id);
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

sub get_id        { shift->{id}                             }
sub get_tag       { shift->{tag}                            }
sub get_buffer    { @{shift->{buffer}}                      }
sub get_parent_id { shift->{parent_id}                      }
sub is_new        { shift->{is_new}                         }
sub set_id        { shift->{id}        = pop                }
sub set_tag       { shift->{tag}       = lc pop             }
sub clear_buffer  { shift->{buffer}    = []                 }
sub set_parent_id { shift->{parent_id} = pop                }
sub set_old       { shift->{is_new}    = 0                  }
sub set_attribute { push @{$_[0]->{buffer}}, [$_[1], $_[2]] }

1;
