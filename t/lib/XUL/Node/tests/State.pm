package XUL::Node::tests::State;

use strict;
use warnings;
use Carp;
use Test::More;
use XUL::tests::Assert;
use XUL::Node;
use XUL::Node::ChangeManager;

use base 'Test::Class';

sub subject_class { 'XUL::Node::State' }

sub create: Test {
	my ($self, $subject) = @_;
	$self->init_state($subject);
	is_xul $subject->flush, ['E2.new.label.E1'];
}

sub change: Test {
	my ($self, $subject) = @_;
	$self->init_state($subject);
	$subject->flush;
	$subject->set_attribute(key1 => 'value1');
	$subject->set_attribute(key2 => 'value2');
	is_xul $subject->flush, [qw(E2.set.key1.value1 E2.set.key2.value2)];
}

sub flush_twice: Test {
	my ($self, $subject) = @_;
	$self->init_state($subject);
	$subject->set_attribute(foo => 'bar');
	$subject->flush;
	is $subject->flush, '';
}

sub init_state {
	my ($self, $subject) = @_;
	$subject->set_id('E2');
	$subject->set_parent_id('E1');
	$subject->set_tag('Label');
}

1;

