package XUL::Node::Application::HelloWorld;

use strict;
use warnings;
use Carp;
use XUL::Node;

use base 'XUL::Node::Application';

sub start { Window(SIZE_TO_CONTENT, Label(value => 'Hello World!')) }

1;
