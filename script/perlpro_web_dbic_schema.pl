#!/usr/bin/env perl
use warnings;
use strict;
use FindBin '$Bin';
use lib "$Bin/../lib";
use DBIx::Class::Schema::Loader ();
use PerlPro::Web ();

my $opts = {
    dump_directory => "$Bin/../lib",
    components => [ 'EncodedColumn', 'InflateColumn::DateTime' ],
    quote_names => 1,
    db_schema => [ 'job', 'company', 'system' ],
};

my $info = PerlPro::Web->model('DB')->connect_info;

DBIx::Class::Schema::Loader::make_schema_at(
    'PerlPro::Schema',
    $opts,
    [ $info->{dsn}, $info->{user}, $info->{password} ],
);
