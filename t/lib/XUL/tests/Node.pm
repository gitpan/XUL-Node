package XUL::tests::Node;

use strict;
use warnings;
use Carp;
use Test::More;
use XUL::tests::Assert;
use XUL::Node;
use XUL::Node::Event;

use base 'Test::Class';

sub subject_class { 'XUL::Node' }

sub set_attribute: Test {
	my ($self, $subject) = @_;
	$subject->set_attribute(tag => 'Label');
	is $subject->get_attribute('tag'), 'Label';
}

sub add_child: Test {
	my ($self, $subject) = @_;
	$subject->set_attribute(tag => 'Box');
	my $child = $self->make_subject(tag => 'Label');
	$subject->add_child($child);
	is_deeply [$subject->children], [$child];
}

sub create_with_children: Test {
	my $self    = shift;
	my $child1  = $self->make_subject(tag => 'Label');
	my $child2  = $self->make_subject(tag => 'Label');
	my $subject = $self->make_subject(tag => 'Box', $child1, $child2);
	is_deeply [$subject->children], [$child1, $child2];
}

sub create_on_parent: Test {
	my ($self, $subject) = @_;
	$subject->tag('Box');
	$subject->Label(value => 'bar');
	is_xul_xml $subject, <<AS_XML;
<Box>
   <Label value="bar"/>
</Box>
AS_XML
}

sub create_with_nice_api: Test {
	my $self = shift;
	my $subject =
		Box(ORIENT_HORIZONTAL,
			Label(value => 'foo'),
			Box(ORIENT_VERTICAL,
				Label(value => 'a label'),
				Button(value => 'a button'),
			),
		);
	is_xul_xml $subject, <<AS_XML;
<Box orient="horizontal">
   <Label value="foo"/>
   <Box orient="vertical">
      <Label value="a label"/>
      <Button value="a button"/>
   </Box>
</Box>
AS_XML
}

sub attach: Test {
	my ($self, $subject) = @_;
	my $listener_called = 0;
	$subject->attach(Click => sub { $listener_called = shift->source });
	$subject->fire_event
		(XUL::Node::Event->new({name => 'Click', source => $subject}));
	is $listener_called, $subject;
}

sub detach: Test {
	my ($self, $subject) = @_;
	my $listener_called = 0;
	$subject->attach(Click => sub { $listener_called = shift->source });
	$subject->detach('Click');
	$subject->fire_event
		(XUL::Node::Event->new({name => 'Click', source => $subject}));
	is $listener_called, 0;
}

sub destroy: Test(4) {
	my ($self, $subject) = @_;
	my $child = $subject->Label;
	ok !$subject->is_destroyed, 'subject exists';
	ok !$child->is_destroyed, 'child exists';
	$subject->destroy;
	ok $subject->is_destroyed, 'subject destroyed';
	ok $child->is_destroyed, 'child destroyed';
}

sub remove_child: Test(2) {
	my ($self, $subject) = @_;
	my $child = $subject->Label;
	$subject->remove_child($child);
	is $subject->child_count, 0, 'child count decreased';
	ok $child->is_destroyed, 'child removed';
}

1;