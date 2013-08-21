use utf8;
use strict;
use warnings;
use Test::More;

use FindBin '$Bin';
use lib "$Bin/lib";

use pQuery;
use PerlPro::TestTools;
use PerlPro::Web::Controller::Public::Company;

my @companies = ( 'Company One', 'Company Two', 'Company Three' );

my $t    = PerlPro::TestTools->new;
my $mech = $t->mech;

{
    $mech->get_ok('/companies', 'company catalog loads ok');

    my $p = $mech->pquery;

    is($p->find('h2')->text, 'Catálogo de Empresas', 'the h2 title is "Catálogo de Empresas"');
    is($p->find('.companies li')->size(), 3, 'there are three companies');
    $p->find('.companies li')->each(sub {
        my $i = shift;
        is(pQuery($_)->find('h4')->text(), $companies[$i], "$companies[$i] is listed in the catalog");
    });
}

{
    $mech->get_ok('/company/company1', 'company1 profile loads ok');
    my $p = $mech->pquery;
    like($p->find('h2')->text, qr{Company One}, q{the company name is where it's supposed to be});
    like($p->find('#company-description')->text, qr{Desc of company one}, q{the company description is where it's supposed to be});
    like($p->find('ul#company-info li')->eq(0)->text, qr{company1\.com}, q{the company website is where it's supposed to be});
    like($p->find('ul#company-info li')->eq(1)->text, qr{a\@perlpro\.com\.br}, q{the company email is where it's supposed to be});
    like($p->find('ul#company-info li')->eq(2)->text, qr{1234\-5678}, q{the company phone number is where it's supposed to be});
}

done_testing();
