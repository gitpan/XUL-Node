package XUL::Node::Application::PeriodicTable::Welcome;

use strict;
use warnings;
use Carp;
use XUL::Node;

use base 'XUL::Node::Application::PeriodicTable::Base';

sub get_demo_box {
	my $self = shift;
	VBox(
		HTML_H3(textNode => 'A demonstration of all XUL-Node widgets'),
		Description(top => '3em', textNode => '
			Adapted from the original Mozilla XUL periodic table, by Alice J.
			Corbin. It is the definitive example of all xul widgets. You can
			fint it at:
		'),
		Box(HTML_Div(HTML_A(
			style    => 'padding-left: 4em; padding-bottom: 3em',
			textNode => 'http://www.hevanet.com/acorbin/xul/top.xul',
			href     => 'http://www.hevanet.com/acorbin/xul/top.xul',
			target   => 'new_browser',
		))),
		GroupBox(
			style => 'color: red; font-weight: bold; border-color: red',
			Caption(label => 'CAVEATS'),
			HTML_Pre(textNode => << 'CAVEATS_TEXT'),

MAJOR ISSUES
			
  * multiple selection is not supported
  * multi column list box does not show 1st column labels
    for some rows
  * trees are not supported yet
  * popups are not supported yet

MINOR ISSUES

  * equalsize attribute will not work
  * multiline labels in button may come out in wrong order
  * menus with no popups may not show

CAVEATS_TEXT
		),
	);
}

1;
