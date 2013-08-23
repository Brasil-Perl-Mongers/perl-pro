use FindBin '$Bin';
use lib "$Bin/lib";

use PerlPro::TestTools;
use PerlPro::Web::Controller::Company::Data;

my $t = PerlPro::TestTools->new( current_page => '/account/home' );

my $m    = $t->mech;
my $page = $t->current_page;
my $auth = $t->auth;

# company one
for my $user ('user1-c1', 'user2-c1') {
    $auth->login_ok($user);
    $m->base_like(qr{$page});
    my $content = $m->text;
    like($content, qr{Company One}, qq{$user - name is there.});
    like($content, qr{Desc of company one}, qq{$user - description is there.});
    like($content, qr{a\@perlpro\.com\.br}, qq{$user - e-mail is there.});
    like($content, qr{b\@perlpro\.com\.br}, qq{$user - e-mail is there.});
    like($content, qr{1234\-5678}, qq{$user - phone is there.});
    like($content, qr{91234\-5678}, qq{$user - phone is there.});
    like($content, qr{http://company1\.com}, qq{$user - website is there.});
    like($content, qr{http://www.company1\.com}, qq{$user - website is there.});
    $auth->logout;
}

# company two
{
    $auth->login_ok('user1-c2');
    $m->base_like(qr{$page});
    my $content = $m->text;
    like($content, qr{Company Two}, qq{user1-c2 - name is there.});
    like($content, qr{Desc of company two}, qq{user1-c2 - description is there.});
    like($content, qr{c\@perlpro\.com\.br}, qq{user1-c2 - e-mail is there.});
    like($content, qr{5678\-1234}, qq{user1-c2 - phone is there.});
    like($content, qr{http://company2\.com}, qq{user1-c2 - website is there.});
    like($content, qr{http://www.company2\.com}, qq{user1-c2 - website is there.});

    TODO: {
        local $TODO = 'not implemented';
        no warnings qw/redefine once/;
        local *Catalyst::Log::error = sub { 1 };

        $m->put_ok('/account/data/description', content => 'New desc of company two');
        $m->get_ok($page);
        like($m->text, qr{New desc of company two}, qq{new desc was saved});
    }

    $auth->logout;
}

done_testing();
