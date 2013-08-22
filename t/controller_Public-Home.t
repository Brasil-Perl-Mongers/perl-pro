use FindBin '$Bin';
use lib "$Bin/lib";

use pQuery;
use PerlPro::TestTools;
use PerlPro::Web::Controller::Public::Home;

my @jobs = ('Catalyst Developer', 'Database analyst', 'Front-end Developer');
my @cmps = ('Company One', 'Company Two', 'Company Three');

my $t    = PerlPro::TestTools->new;
my $mech = $t->mech;

{
    $mech->get_ok('/home', 'home page loads ok');

    my $p = $mech->pquery;

TODO: {
    local $TODO = "should test promoted jobs";
    fail('not implemented');
}

    is($p->find('.hot-jobs .carousel')->size(), 1, 'there is a carousel in the page');
    is($p->find('.recent-jobs li')->size(), 3, 'there are three recent jobs');
    $p->find('.recent-jobs li')->each(sub {
        my $i = shift;
        is(pQuery($_)->find('.position-name')->text, $jobs[$i], "job $i is correct in the recent jobs list");
        is(pQuery($_)->find('.company-name')->text, $cmps[$i], "company $i is correct in the recent jobs list");
    });
}

done_testing();
