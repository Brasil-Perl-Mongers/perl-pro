use FindBin '$Bin';
use lib "$Bin/lib";

use PerlPro::TestTools;
use PerlPro::Web::Controller::Company::Job;

my $t = PerlPro::TestTools->new( current_page => '/account/my_jobs' );
my $m = $t->mech;
my $page = $t->current_page;

# list my jobs
for my $user ('user1-c1', 'user2-c1') {
    $t->auth->login_ok($user);

    my $q = $m->pquery;
    like($q->find('h2')->eq(0)->text, qr{Meus anúncios}, 'title is correct');

    my $trs = $q->find('.my_jobs tbody tr');
    is($trs->size, 1, 'only one job registered');
    my $tr = $trs->eq(0);
    like($tr->find('.published_at')->text, qr[\d{2}\.\d{2}], 'job published date seems correct');
    ok($tr->find('.active')->size && !$tr->find('.inactive')->size, 'job is active');
    like($tr->find('.description')->text, qr[Catalyst Developer], 'job title is correct');

    $t->auth->logout();
}

# create job
TODO: {
    local $TODO = "not implemented yet";
    fail('create job');
    fail('update job');
    fail('remove job');
}

done_testing();
