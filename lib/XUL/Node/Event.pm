package XUL::Node::Event;

use strict;
use warnings;
use Carp;

sub make_event {
	my ($class, $request) = @_;
	my $event  = $class->new($request);
	my $name   = $event->name;
	my $method = "handle_side_effects_$name";
	croak "unknown event name: [$name]" unless $event->can($method);
	$event->$method($event);
	return $event;
}

sub new {
	my ($class, $request) = @_;
	my $self = bless {}, $class;
	croak "cannot create event with no source"
		unless $request->{source};
	croak "cannot create event with no name"
		unless $request->{name};
	croak "illegal event name"
		unless $request->{name} =~ /^\w+$/;
	$self->{$_} = $request->{$_} for keys %$request;
	return $self;
}

sub AUTOLOAD {
	my $self = shift;
	my $key  = our $AUTOLOAD;
	return if $key =~ /DESTROY$/;
	$key =~ s/^.*:://;
	return $self->{$key} if @_ == 0;
	$self->{$key} = shift;
}

sub handle_side_effects_Click {
	my ($self, $event) = @_;
	my $checked = $event->checked;
	$checked = defined $checked && $checked eq 'true'? 1: 0;
	$event->checked($checked);
	$event->source->checked($checked);
}

sub handle_side_effects_Change {
	my ($self, $event) = @_;
	$event->source->value($event->value);
}

sub handle_side_effects_Select {
	my ($self, $event) = @_;
	$event->source->selectedIndex($event->selectedIndex);
}

sub handle_side_effects_Pick {
	my ($self, $event) = @_;
	$event->source->color($event->color);
}

1;

=head1 NAME

XUL::Node::Event - a user interface event

=head1 SYNOPSYS

  # listening to existing widget
  $button->attach(Change => sub { print 'clicked!' });

  # listening to widget in constructor, listener prints event value
  TextBox(Change => sub { print shift->value });

  # more complex listeners
  $check_box->attach(Click => sub {
     my $event = shift; # XUL::Node::Event object is only para
     print
       'source: '.   $event->source,  # source widget, a XUL::Node object
       ', name: '.   $event->name,    # Click
       ', checked:'. $event->checked; # Perl boolean
  });

=head1 DESCRIPTION

Events are objects recieved as the only argument to a widget listener
callback. You can interogate them for information concerning the event.

Each type of widget has one or more event types that it fires. Buttons
fire C<Click>, for example, but list boxes fire C<Select>.

Events from the UI can have side effects: a change in the textbox on the
screen, requires that the C<value> attribute of the Perl textbox object
change as well, to stay in sync. This happens automatically, and
I<before> listener code is run.

=head1 EVENT TYPES

All events have a C<name> and a C<source>. Each possible event name, can
have additional methods for describing that specific event:

=over 4

=item Click

C<CheckBox, Button, Radio, ToolBarButton, MenuItem when
inside a Menu>. Checkbox and radio events provide a method C<checked>,
that returns the widget state as a boolean.

=item Change

C<TextBox>. C<value> will return the new textbox value.

=item Select

C<MenuList, ListBox, Button with TYPE_MENU>. C<selectedIndex> will return
the index of the selected item in the widget.

=item Pick

C<ColorPicker>. C<color> will return the RGB value of the color selected.

=back

=cut
