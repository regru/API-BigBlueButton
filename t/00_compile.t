#!/usr/bin/perl

use strict;
use warnings;
use Test::More  tests => 3;

use FindBin qw/ $Bin /;
use lib "$Bin/../lib";

my @modules = qw/ BigBlueButton::API BigBlueButton::API::Requests BigBlueButton::API::Response /;

for my $module ( @modules ) {
    require_ok( $module );
}

done_testing;
