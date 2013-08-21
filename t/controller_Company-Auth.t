use strict;
use warnings;
use Test::More;

use FindBin '$Bin';
use lib "$Bin/lib";

use PerlPro::TestTools;
use PerlPro::Web::Controller::Company::Auth;

my $t = PerlPro::TestTools->new( current_page => '/account/home' );

my $auth = $t->auth;

$auth->login_ok('user1-c1');
$auth->logout();
$auth->login_ok('user2-c1');
$auth->logout();
$auth->login_ok('user1-c2');
$auth->logout();
$auth->login_ok('user1-c3');
$auth->logout();

$auth->login_not_ok('user1-c1' => 'bogus');
$auth->login_not_ok('user2-c1' => 'bogus');
$auth->login_not_ok('user1-c2' => 'bogus');
$auth->login_not_ok('user1-c3' => 'bogus');
$auth->login_not_ok('bogus'    => 'bogus');

done_testing();
