#!/usr/bin/env perl
use warnings;
use strict;

use FindBin '$Bin';
use lib "$Bin/../lib";

use PerlPro::TestTools;

my $t = PerlPro::TestTools->new;
$t->clear_fixtures;

print "cleared.\n";
