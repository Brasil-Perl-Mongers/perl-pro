use strict;
use warnings;
use Test::More;

use FindBin '$Bin';
use lib "$Bin/lib";

use PerlPro::TestTools;
use PerlPro::Web::Controller::Company::Register;

my $t = PerlPro::TestTools->new( current_page => '/account/new' );

my $m       = $t->mech;
my $page    = $t->current_page;
my $db      = $t->db;
my $user_rs = $db->resultset('User');
my $comp_rs = $db->resultset('Company');

$user_rs->search({ login => 'john' })->delete;
$comp_rs->search({ name => 'Test Company' })->delete;

# find link from home
{
    $m->get_ok('/', 'got homepage');
    $m->follow_link_ok({ url_regex => qr{$page} }, 'found link to create account');
    $m->base_like(qr{$page}, 'got to the correct page');
}

# fail validation in the user section
{
    no warnings 'redefine';
    local *Catalyst::Log::warn = sub { 1 };

    is($user_rs->count({ login => 'john' }), 0, q{no user 'john' in the DB});
    is($comp_rs->count({ name => 'Test Company' }), 0, q{no company 'Test Company' in the DB});

    $m->get_ok($page, 'request for /account/new is successful');
    $m->submit_form_ok({
        with_fields => {
            'user.register.name'             => 'Mr. John Doe',
            'user.register.email'            => 'mr@@johndoe.com', # invalid
            'user.register.login'            => 'john',
            'user.register.password'         => 'doe',
            'user.register.confirm_password' => 'doe',
            'company.register.name'          => 'Test Company',
            'company.register.description'   => 'Lorem ipsum dolor sit amet...',
            'company.register.email'         => 'mr.john@doe.com',
            'company.register.phone'         => '1234-5678',
            'company.register.address'       => 'Somewhere, Someroad, 25',
            'company.register.city'          => 'Dogville',
            'company.register.state'         => 'SP',
        },
    }, 'the form submission to create account is successful');

    is($user_rs->count({ login => 'john' }), 0, q{user wasn't saved});
    is($comp_rs->count({ name => 'Test Company' }), 0, q{company wasn't saved});

    $m->base_like(qr{$page}, q{we're still at /account/new});

    my $form = $m->form_with_fields( 'user.register.name' );
    is($form->value('user.register.name'), 'Mr. John Doe', 'user name is set correctly in the form');
    is($form->value('user.register.login'), 'john', 'user login is set correctly in the form');
    is($form->value('company.register.name'), 'Test Company', 'company name is set correctly in the form');
    is($form->value('company.register.description'), 'Lorem ipsum dolor sit amet...', 'company description is set correctly in the form');
    is($form->value('company.register.email'), 'mr.john@doe.com', 'company e-mail is set correctly in the form');
    is($form->value('company.register.phone'), '1234-5678', 'company phone is set correctly in the form');
    is($form->value('company.register.address'), 'Somewhere, Someroad, 25', 'company location is set correctly in the form');
    is($form->value('company.register.city'), 'Dogville', 'company city is set correctly in the form');
    is($form->value('company.register.state'), 'SP', 'company state is set correctly in the form');
}

# fail validation in the company section
{
    no warnings 'redefine';
    local *Catalyst::Log::warn = sub { 1 };

    is($user_rs->count({ login => 'john' }), 0, q{no user 'john' in the DB});
    is($comp_rs->count({ name => 'Test Company' }), 0, q{no company 'Test Company' in the DB});

    $m->get_ok($page, 'request for /account/new is successful');
    $m->submit_form_ok({
        with_fields => {
            'user.register.name'             => 'Mr. John Doe',
            'user.register.email'            => 'mr@johndoe.com',
            'user.register.login'            => 'john',
            'user.register.password'         => 'doe',
            'user.register.confirm_password' => 'doe',
            'company.register.name'          => 'Test Company',
            'company.register.description'   => 'Lorem ipsum dolor sit amet...',
            'company.register.email'         => 'mr.john@.com', # invalid
            'company.register.phone'         => '1234-5678',
            'company.register.address'       => 'Somewhere, Someroad, 25',
            'company.register.city'          => 'Dogville',
            'company.register.state'         => 'SP',
        },
    }, 'the form submission to create account is successful');

    is($user_rs->count({ login => 'john' }), 0, q{user wasn't saved});
    is($comp_rs->count({ name => 'Test Company' }), 0, q{company wasn't saved});

    $m->base_like(qr{$page}, q{we're still at /account/new});

    my $form = $m->form_with_fields( 'user.register.name' );
    is($form->value('user.register.name'), 'Mr. John Doe', 'user name is set correctly in the form');
    is($form->value('user.register.email'), 'mr@johndoe.com', 'user email is set correctly in the form');
    is($form->value('user.register.login'), 'john', 'user login is set correctly in the form');
    is($form->value('company.register.name'), 'Test Company', 'company name is set correctly in the form');
    is($form->value('company.register.description'), 'Lorem ipsum dolor sit amet...', 'company description is set correctly in the form');
    is($form->value('company.register.phone'), '1234-5678', 'company phone is set correctly in the form');
    is($form->value('company.register.address'), 'Somewhere, Someroad, 25', 'company location is set correctly in the form');
    is($form->value('company.register.city'), 'Dogville', 'company city is set correctly in the form');
    is($form->value('company.register.state'), 'SP', 'company state is set correctly in the form');
}

# successfully register
{
    is($user_rs->count({ login => 'john' }), 0, q{no user 'john' in the DB});
    is($comp_rs->count({ name => 'Test Company' }), 0, q{no company 'Test Company' in the DB});

    $m->get_ok($page, 'request for /account/new is successful');
    $m->submit_form_ok({
        with_fields => {
            'user.register.name'             => 'Mr. John Doe',
            'user.register.email'            => 'mr@johndoe.com',
            'user.register.login'            => 'john',
            'user.register.password'         => 'doe',
            'user.register.confirm_password' => 'doe',
            'company.register.name'          => 'Test Company',
            'company.register.description'   => 'Lorem ipsum dolor sit amet...',
            'company.register.email'         => 'mr.john@doe.com',
            'company.register.phone'         => '1234-5678',
            'company.register.address'       => 'Somewhere, Someroad, 25',
            'company.register.city'          => 'Dogville',
            'company.register.state'         => 'SP',
        },
    }, 'the form submission to create account is successful');

    is($user_rs->count({ login => 'john' }), 1, q{user was saved});
    is($comp_rs->count({ name => 'Test Company' }), 1, q{company was saved});

# TODO: where should we go?
#    $m->base_like(qr{$page}, q{we're still at /account/new});
}

$user_rs->search({ login => 'john' })->delete;
$comp_rs->search({ name => 'Test Company' })->delete;

done_testing();
