package XUL::Node::Application::PeriodicTable::MenuBars;

use strict;
use warnings;
use Carp;
use XUL::Node;

use base 'XUL::Node::Application::PeriodicTable::Base';

sub get_demo_box {
	my $self = shift;
	my ($images, $box) = ({}, undef);
	VBox(FLEX,
		GroupBox(
			Caption(label => 'non-functioning tool and menu bars'),
			ToolBox(
				ToolBar(
					Label(value => 'This is a toolbar:'),
					ToolBarSeparator,
					ToolBarButton(
						label     => 'Button',
						accesskey => 'B',
						onclick   => 'alert("Ouch!")',
					),
					ToolBarButton(TYPE_CHECKBOX, label => 'Check'),
					ToolBarButton(DISABLED, label => 'Disabled'),
					ToolBarButton
						(label => 'Image', image => 'images/betty_boop.xbm'),
				),
				ToolBar(
					Label(value => 'This is another toolbar:'),
					ToolBarSeparator,
					ToolBarButton(TYPE_RADIO, label => 'Radio1', name => 'radio'),
					ToolBarButton(TYPE_RADIO, label => 'Radio2', name => 'radio'),
					ToolBarButton(TYPE_RADIO, label => 'Radio3', name => 'radio'),
				),
				MenuBar(
					Label(value => 'This is a menubar'),
					ToolBarSeparator,
					Menu(label => 'Radio', accesskey => 'R',
						MenuPopup(
							MenuItem(TYPE_RADIO, label => 'Radio1', name => 'radio'),
							MenuItem(TYPE_RADIO, label => 'Radio2', name => 'radio'),
							MenuItem(TYPE_RADIO, label => 'Radio3', name => 'radio'),
						),
					),
					Menu(label => 'Checkbox', accesskey => 'C',
						MenuPopup(
							MenuItem(TYPE_CHECKBOX, label => 'Check1'),
							MenuItem(TYPE_CHECKBOX, label => 'Check2'),
							MenuItem(TYPE_CHECKBOX, label => 'Check3'),
						),
					),
					Menu(label => 'Cascading', accesskey => 'a',
						MenuPopup(
							Menu(label => 'More',
								MenuPopup(
									MenuItem(label => 'A'),
									MenuItem(label => 'B'),
									MenuItem(label => 'C'),
									MenuSeparator,
									Menu(label => 'More',
										MenuPopup(
											MenuItem(label => '1'),
											MenuItem(label => '2'),
											MenuItem(label => '3'),
										),
									),
								),
							),
							MenuSeparator,
							MenuItem(label => 'X'),
							MenuItem(label => 'Y'),
							MenuItem(label => 'Z'),
						),
					),
					Menu(label => 'Images', accesskey => 'I',
						MenuPopup(
							MenuItem(
								label => 'Left',
								class => 'menuitem-iconic',
								src   => 'images/betty_boop.xbm',
							),
							MenuItem(DIR_REVERSE,
								label => 'Right',
								class => 'menuitem-iconic',
								src   => 'images/betty_boop.xbm',
							),
							MenuItem(label => 'None'),
						),
					),
					Spacer(FLEX),
					Menu(label => 'Help', accesskey => 'H',
						MenuPopup(MenuItem(label => 'This is help')),
					),
				),
				# these dont show. why?
				MenuBar(DIR_REVERSE,
					Menu(label => 'Menubar'),
					Menu(label => 'with'),
					Menu(label => 'its'),
					Menu(label => 'grippy'),
					Spacer(FLEX),
					Menu(label => 'here->'),
				),
				MenuBar(grippyhidden => 1,
					Menu(label => 'Menubar'),
					Menu(label => 'with'),
					Menu(label => 'its'),
					Menu(label => 'grippy'),
					Menu(label => 'hidden'),
				),
			),
		),
		GroupBox(FLEX,
			Caption(label => 'functioning tool and menu bars'),
			ToolBox(
				ToolBar(
					ToolBarButton(label => 'Color:'),
					ToolBarButton(TYPE_RADIO,
						name  => 'color',
						image => 'images/red_apple.png',
						Click => sub { $box->style('background-color:red') },
					),
					ToolBarButton(TYPE_RADIO,
						name  => 'color',
						image => 'images/yellow_apple.png',
						Click => sub { $box->style('background-color:yellow') },
					),
					ToolBarButton(TYPE_RADIO,
						name  => 'color',
						image => 'images/green_apple.png',
						Click => sub { $box->style('background-color:green') },
					),
					ToolBarButton(TYPE_RADIO,
						name  => 'color',
						image => 'images/cyan_apple.png',
						Click => sub { $box->style('background-color:cyan') },
					),
					ToolBarButton(TYPE_RADIO,
						name  => 'color',
						image => 'images/blue_apple.png',
						Click => sub { $box->style('background-color:blue') },
					),
					ToolBarButton(TYPE_RADIO,
						name  => 'color',
						image => 'images/magenta_apple.png',
						Click => sub { $box->style('background-color:magenta') },
					),
				),
				MenuBar(
					Menu(label => 'Color', accesskey => 'o',
						MenuPopup(
							MenuItem(TYPE_RADIO, name => 'color2', label => 'Red',
								Click => sub { $box->style('background-color:red') },
							),
							MenuItem(TYPE_RADIO, name => 'color2', label => 'Yellow',
								Click => sub { $box->style('background-color:yellow') },
							),
							MenuItem(TYPE_RADIO, name => 'color2', label => 'Green',
								Click => sub { $box->style('background-color:green') },
							),
							MenuItem(TYPE_RADIO, name => 'color2', label => 'Cyan',
								Click => sub { $box->style('background-color:cyan') },
							),
							MenuItem(TYPE_RADIO, name => 'color2', label => 'Blue',
								Click => sub { $box->style('background-color:blue') },
							),
							MenuItem(TYPE_RADIO, name => 'color2', label => 'Magenta',
								Click => sub { $box->style('background-color:magenta') },
							),
						),
					),
					Menu(label => 'Image', accesskey => 'm',
						MenuPopup(
							MenuItem(TYPE_CHECKBOX,
								label   => 'Betty',
								checked => 1,
								Click => sub { $images->{1}->hidden(!shift->checked) },
							),
							MenuItem(TYPE_CHECKBOX,
								label   => 'Chick',
								checked => 1,
								Click => sub { $images->{2}->hidden(!shift->checked) },
							),
							MenuItem(TYPE_CHECKBOX,
								label   => 'Blind Chicken',
								checked => 1,
								Click => sub { $images->{3}->hidden(!shift->checked) },
							),
						),
					),
				),
			),
			$box = Box(FLEX, ALIGN_CENTER,
				Spacer(FLEX),
				$images->{1} = Image(src => 'images/betty_boop.xbm'),
				Spacer(FLEX),
				$images->{2} = Image(src => 'images/chick.png'),
				Spacer(FLEX),
				$images->{3} = Image(src => 'images/BC-R.jpg'),
				Spacer(FLEX),
			),
		),
		StatusBar(
			StatusBarPanel(label => 'This is a statusbarpanel.'),
			StatusBarPanel(label => 'As is this.'),
			StatusBarPanel(FLEX, label => 'And also this....'),
			StatusBarPanel(label => 'Click Me!', onclick => 'alert("Ouch")'),
		),
	);
}

1;
