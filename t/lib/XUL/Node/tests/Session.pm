package XUL::Node::tests::Session;

use strict;
use warnings;
use Carp;
use Test::More;
use XUL::tests::Assert;
use XUL::Node::Session;

use base 'Test::Class';

sub subject_class { 'XUL::Node::Session' }

sub hello_world: Test {
	is_xul
		pop->handle_boot({name => 'HelloWorld'}),
		[qw(
			E2.new.window.0
			E2.set.sizeToContent.1
			E1.new.label.E2.0
			E1.set.value.Hello_World!
		)];
}

sub button_example: Test {
	my ($self, $subject) = @_;
	$subject->handle_boot({name => 'ButtonExample'});
	is_xul
		$subject->handle_event({name => 'Click', source => 'E2'}),
		['E2.set.label.1'];
}

sub button_example_2_clicks: Test {
	my ($self, $subject) = @_;
	$subject->handle_boot({name => 'ButtonExample'});
	$subject->handle_event({name => 'Click', source => 'E2'});
	is_xul
		$subject->handle_event({name => 'Click', source => 'E2'}),
		['E2.set.label.2'];
}

sub event_side_effects_textbox: Test {
	my ($self, $subject) = @_;
	$subject->handle_boot({name => 'TextBoxExample'});
	$subject->handle_event({name => 'Change', source => 'E1', value => 'foo'});
	is $subject->event_manager->get_node('E1')->value, 'foo';
}

sub event_side_effects_checkbox: Test(2) {
	my ($self, $subject) = @_;
	$subject->handle_boot({name => 'CheckBoxExample'});
	my $check_box = $subject->event_manager->get_node('E1');
	$subject->handle_event
		({name => 'Click', source => 'E1', checked => 'true'});
	is $check_box->checked, 1, 'checked';
	$subject->handle_event({name => 'Click', source => 'E1', checked => ''});
	is $check_box->checked, 0, 'unchecked';
}

1;

