use strict;
use warnings;
use Test::More;

use FindBin '$Bin';
use lib "$Bin/lib";

use pQuery;
use PerlPro::TestTools;
use PerlPro::Web::Controller::Public::Job;

my $t = PerlPro::TestTools->new;
$t->require_fixtures;
my $mech = $t->mech;
my $job_rs = $t->db->resultset('Job');

{
    $mech->get_ok('/jobs', 'job listing loads ok');

    my $p = $mech->pquery;

    # TODO
    # see how the company catalog test is implemented, and port here
}

# TODO:
# test search, with as many filters as possible
# this is probably going to be the biggest test script

{
    ok(my $job = $job_rs->search({ company => 'company1' })->first, 'found job in db');

    $mech->get_ok('/job/' . $job->id, 'job view loads ok');
    my $p = $mech->pquery;
    # TODO:
    # there should be a more specific way to search
    # instead of getting the whole .job-view-row at once
    my $job_details = $p->find('.job-view-row')->eq(0)->text;
    like($p->find('h2')->text, qr{Catalyst Developer}, q{the job title is where it's supposed to be});
    like($job_details, qr{We need a good Catalyst developer}, q{the job description is where it's supposed to be});
    like($job_details, qr{R\$\s*10\.000,00}, q{the salary is where it's supposed to be});
}

done_testing();
