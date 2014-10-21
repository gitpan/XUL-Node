package XUL::Node::tests::ChangeManager;

use strict;
use warnings;
use Carp;
use Test::More;
use XUL::tests::Assert;
use XUL::Node;
use XUL::Node::ChangeManager;

use base 'Test::Class';

sub subject_class { 'XUL::Node::ChangeManager' }

sub window_registration: Test {
	my ($self, $subject) = @_;
	my $window = $self->make_window($subject);
	is_deeply $subject->windows, [$window];
}

sub create: Test {
	my ($self, $subject) = @_;
	$self->is_buffer($subject, [qw(
		E2.new.window.0
		E1.new.label.E2.0
		E1.set.value.foo
	)]);
}

sub change: Test {
	my ($self, $subject) = @_;
	my $window = $self->make_window($subject);
	$self->is_buffer(
		$subject,
		['E1.set.value.bar'],
		sub { $window->first_child->value('bar') },
	);
}

sub empty_flush: Test {
	my ($self, $subject) = @_;
	$self->make_window($subject);
	$self->is_buffer($subject, [], sub {});
}

sub remove_child: Test {
	my ($self, $subject) = @_;
	my $window = $self->make_window($subject);
	my $label  = $window->first_child;
	$self->is_buffer
		($subject, ['E1.bye'], sub { $window->remove_child($label) });
}

sub create_at_index: Test {
	my ($self, $subject) = @_;
	$self->is_buffer($subject, [qw(
		E1.new.window.0
		E4.new.label.E1.0
		E2.new.label.E1.0
		E3.new.label.E1.1
	)], sub {
		my $window = Window;
		$window->Label;
		$window->Label;
		$window->add_child(Label, 0);
	});
}

# assertions and helpers ------------------------------------------------------

sub is_buffer {
	my ($self, $subject, $expected, $code) = @_;
	local $Test::Builder::Level = $Test::Builder::Level + 1;
	my ($actual, $window) = $self->make_window($subject, $code);
	is_xul($actual, $expected) if $expected;
	return $window;
}

sub make_window {
	my ($self, $subject, $code) = @_;
	my $window;
	$code ||= sub { $window = Window(Label(value => 'foo')) };
	my $flushed_buffer = $subject->run_and_flush($code);
	return wantarray? ($flushed_buffer, $window): $window;
}

1;

