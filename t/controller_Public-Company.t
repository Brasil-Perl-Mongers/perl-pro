use utf8;
use strict;
use warnings;
use Test::More;

use FindBin '$Bin';
use lib "$Bin/lib";

use PerlPro::TestTools;
use PerlPro::Web::Controller::Public::Company;

my $t = PerlPro::TestTools->new;
$t->require_fixtures;
my $mech = $t->mech;

{
    $mech->get_ok('/companies', 'company catalog loads ok');

    my $p = $mech->pquery;

    is($p->find('h2')->text, 'Catálogo de Empresas', 'the h2 title is "Catálogo de Empresas"');
    is($p->find('.companies li')->size(), 3, 'there are three companies');
}

{
    $mech->get_ok('/company/company1', 'company1 profile loads ok');
    my $p = $mech->pquery;
    like($p->find('h2')->text, qr{Company One}, q{the company name is where it's supposed to be});
}

done_testing();
