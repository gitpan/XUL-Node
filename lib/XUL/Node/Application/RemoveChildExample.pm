package XUL::Node::Application::RemoveChildExample;

use strict;
use warnings;
use Carp;
use XUL::Node;

use base 'XUL::Node::Application';

sub start {
	my $i = 0;
	my $list;
	Window(
		VBox(FILL,
			HBox(
				Button(label => 'add'   , Click => sub { add_item   ($list) }),
				Button(label => 'remove', Click => sub { remove_item($list) }),
			),
			$list = ListBox(FILL),
		),
	);
}

sub add_item {
	my $list  = shift;
	my $index = $list->child_count + 1;
	$list->ListItem(label => "item #$index");
}

sub remove_item {
	my $list = shift;
	my $index = $list->child_count;
	return unless $index;
	$list->remove_child($list->children->[$index - 1]);
}

1;
