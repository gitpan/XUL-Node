#!perl

require 5.008;

use strict;
use warnings;
use Carp qw(verbose croak);
use FindBin;
use lib ("$FindBin::Bin/../lib", "$FindBin::Bin/lib");
use Aspect;
use Test::Class;

$| = 1;
$ENV{TEST_VERBOSE} = 0;

sub runtime_use {
	my $package = shift;
	eval "use $package";
	croak "cannot use: [$package]: $@" if $@;
}

my @test_class_names;

BEGIN {
	my @ALL_TESTS = qw(
		XUL::tests::Node
		XUL::Node::tests::State
		XUL::Node::tests::ChangeManager
		XUL::Node::tests::Session
		XUL::Node::tests::SessionManager
	);

	my $thing = $ARGV[0];
	if ($thing) {
		$thing =~ s/(::)?([^:]+)?$/${
			\( $1 || '')
		}tests::${
			\( $2 || '')
		}/;
		@test_class_names = ($thing);
	} else {
		@test_class_names = @ALL_TESTS;
	}

	runtime_use $_ for @test_class_names;
}

aspect TestClass => call qr/.*::tests::.*/;

Test::Class->runtests(@test_class_names);

1;

=head1 NAME

run_tests.pl - run Rui unit tests

=head1 SYNOPSIS

  # run all tests
  perl all_tests.t

  # a specific test case, no need to add the tests:: part
  perl all_tests.t XUL::Node

=cut
