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
	my $window;
	$subject->run_and_flush
		(sub { $window = Window(Label(value => 'foo')) });
	is_deeply $subject->windows, [$window];
}

sub create: Test {
	my ($self, $subject) = @_;
	$self->is_buffer($subject, [qw(
		E2.new.window.0
		E1.new.label.E2
		E1.set.value.foo
	)]);
}

sub change: Test {
	my ($self, $subject) = @_;
	my $window = $self->is_buffer($subject);
	$self->is_buffer(
		$subject,
		['E1.set.value.bar'],
		sub { $window->children->[0]->value('bar') },
	);
}

sub empty_flush: Test {
	my ($self, $subject) = @_;
	$self->is_buffer($subject);
	$self->is_buffer($subject, [], sub {});
}

sub is_buffer {
	my ($self, $subject, $expected, $code) = @_;
	local $Test::Builder::Level = $Test::Builder::Level + 1;
	my $window;
	$code ||= sub { $window = Window(Label(value => 'foo')) };
	my $actual = $subject->run_and_flush($code);
	is_xul($actual, $expected) if $expected;
	return $window;
}

1;

