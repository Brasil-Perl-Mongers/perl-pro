use FindBin '$Bin';
use lib "$Bin/lib";

use PerlPro::TestTools;
use PerlPro::Web::Controller::Company::Job;

my $t = PerlPro::TestTools->new( current_page => '/account/my_jobs' );
my $m = $t->mech;
my $page = $t->current_page;
my $job_to_be_updated = 0;

sub get_job {
    $t->db->resultset('Job')->find($job_to_be_updated)
}
sub get_max_id {
    $t->db->resultset('Job')->search({}, { order_by => { -desc => 'id' } })->first->id;
}

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
{
    my $max_id = get_max_id();

    $t->auth->login_ok('user1-c2');
    $m->get_ok('/account/job/new');

    _values_ok({
        id                  => '',
        status              => 'active',
        title               => '',
        description         => '',
        vacancies           => '',
        phone               => '',
        email               => '',
        wages               => '',
        wages_for           => '',
        hours               => '',
        hours_by            => '',
        is_at_office        => '',
        contract_type       => '',
        required_attributes => '',
        desired_attributes  => '',
    });

    _submit_ok({
        status              => 'active',
        title               => 'Test job title 1',
        description         => 'Test job desc 1',
        phone               => '(11) 91234-5676',
        email               => 'abcd',              # invalid
        vacancies           => '1',
        wages               => 'R$ 1.000.000,56',  # 2 dots, 1 comma
        wages_for           => 'month',
        hours               => 40,
        hours_by            => 'week',
        is_at_office        => 1,
        contract_type       => 'clt',
        required_attributes => 'Moose,DBIx::Class,Ser pró-ativo',
        desired_attributes  => 'jQuery,HTML5',
    }, 'submit form with invalid e-mail');

    is(get_max_id(), $max_id, 'no job was inserted');

    _values_ok({
        id                  => '',
        status              => 'active',
        title               => 'Test job title 1',
        description         => 'Test job desc 1',
        phone               => '(11) 91234-5676',
        email               => 'abcd',              # invalid
        vacancies           => '1',
        wages               => 'R$ 1.000.000,56',  # 2 dots, 1 comma
        wages_for           => 'month',
        hours               => 40,
        hours_by            => 'week',
        is_at_office        => 1,
        contract_type       => 'clt',
        required_attributes => 'Moose,DBIx::Class,Ser pró-ativo',
        desired_attributes  => 'jQuery,HTML5',
    }, 'invalid e-mail');

    _submit_ok({
        status              => 'active',
        title               => '',                  # required
        description         => 'Test job desc 1',
        phone               => '(11) 91234-5676',
        email               => 'abcd@andre.com',
        vacancies           => '1',
        wages               => 'R$ 1.000.000,56',  # 2 dots, 1 comma
        wages_for           => 'month',
        hours               => 40,
        hours_by            => 'week',
        is_at_office        => 1,
        contract_type       => 'clt',
        required_attributes => 'Moose,DBIx::Class,Ser pró-ativo',
        desired_attributes  => 'jQuery,HTML5',
    }, 'submit form with missing title');

    is(get_max_id(), $max_id, 'no job was inserted');

    _values_ok({
        id                  => '',
        status              => 'active',
        title               => '',                 # required
        description         => 'Test job desc 1',
        phone               => '(11) 91234-5676',
        email               => 'abcd@andre.com',
        vacancies           => '1',
        wages               => 'R$ 1.000.000,56',  # 2 dots, 1 comma
        wages_for           => 'month',
        hours               => 40,
        hours_by            => 'week',
        is_at_office        => 1,
        contract_type       => 'clt',
        required_attributes => 'Moose,DBIx::Class,Ser pró-ativo',
        desired_attributes  => 'jQuery,HTML5',
    }, 'missing title');

    _submit_ok({
        status              => 'active',
        title               => 'Test job title 1',
        description         => 'Test job desc 1',
        phone               => '(11) 91234-5676',
        email               => 'abcd@andre.com',
        vacancies           => '1',
        wages               => 'R$ 1.000.000,56',  # 2 dots, 1 comma
        wages_for           => 'month',
        hours               => 40,
        hours_by            => 'week',
        is_at_office        => 1,
        contract_type       => 'clt',
        required_attributes => 'Moose,DBIx::Class,Ser pró-ativo',
        desired_attributes  => 'jQuery,HTML5',
    }, 'submit valid form');

    my $new_max = get_max_id();
    cmp_ok($new_max, '>', $max_id, 'a job was created in the db');

    if ($new_max <= $max_id) {
        BAIL_OUT('expected job to be inserted');
    }

    $job_to_be_updated = $new_max;

    is_deeply(
        {
            map { ( $_->attribute => $_->required_or_desired ) }
              get_job()->attributes->all
        },
        {
            'Moose'         => 'required',
            'DBIx::Class'   => 'required',
            'Ser pró-ativo' => 'required',
            'jQuery'        => 'desired',
            'HTML5'         => 'desired',
        },
        'attributes are correctly set in the db'
    );


    $t->auth->logout();
}

# update job
{
    $t->auth->login_ok('user1-c2');
    $m->get_ok('/account/job/' . $job_to_be_updated);

    _values_ok({
        id                  => $job_to_be_updated,
        status              => 'active',
        title               => 'Test job title 1',
        description         => 'Test job desc 1',
        phone               => '(11) 91234-5676',
        email               => 'abcd@andre.com',
        vacancies           => '1',
        wages               => qr{^R\$\s*1.000.000,56$},
        wages_for           => 'month',
        hours               => 40,
        hours_by            => 'week',
        is_at_office        => 1,
        contract_type       => 'clt',
        required_attributes => 'Moose,DBIx::Class,Ser pró-ativo',
        desired_attributes  => 'jQuery,HTML5',
    }, 'load to update');

    _submit_ok({
        status              => 'active',
        title               => 'Test job title 1',
        description         => 'Test job desc 1',
        phone               => '(11) 91234-5676',
        email               => 'abcd@andre.com',
        vacancies           => '1',
        wages               => '',                  # required
        wages_for           => 'month',
        hours               => 40,
        hours_by            => 'week',
        is_at_office        => 1,
        contract_type       => 'clt',
        required_attributes => 'Moose,DBIx::Class,Ser pró-ativo',
        desired_attributes  => 'jQuery,HTML5',
    }, 'submit form missing wages');

    like(get_job()->wages, qr{^R\$\s*1.000.000,56$}, 'job was not updated');
    is(get_max_id(), $job_to_be_updated, 'no job was inserted');

    _values_ok({
        id                  => $job_to_be_updated,
        status              => 'active',
        title               => 'Test job title 1',
        description         => 'Test job desc 1',
        phone               => '(11) 91234-5676',
        email               => 'abcd@andre.com',
        vacancies           => '1',
        wages               => '',
        wages_for           => 'month',
        hours               => 40,
        hours_by            => 'week',
        is_at_office        => 1,
        contract_type       => 'clt',
        required_attributes => 'Moose,DBIx::Class,Ser pró-ativo',
        desired_attributes  => 'jQuery,HTML5',
    }, 'missing wages');

    _submit_ok({
        status              => 'active',
        title               => 'Test job title 1',
        description         => 'Test job desc 1',
        phone               => '(11) 91234-5676',
        email               => 'abcd@andre.com',
        vacancies           => '1',
        wages               => 'invalid',           # invalid
        wages_for           => 'month',
        hours               => 40,
        hours_by            => 'week',
        is_at_office        => 1,
        contract_type       => 'clt',
        required_attributes => 'Moose,DBIx::Class,Ser pró-ativo',
        desired_attributes  => 'jQuery,HTML5',
    }, 'submit form with invalid wages');

    like(get_job()->wages, qr{^R\$\s*1.000.000,56$}, 'job was not updated');
    is(get_max_id(), $job_to_be_updated, 'no job was inserted');

    _values_ok({
        id                  => $job_to_be_updated,
        status              => 'active',
        title               => 'Test job title 1',
        description         => 'Test job desc 1',
        phone               => '(11) 91234-5676',
        email               => 'abcd@andre.com',
        vacancies           => '1',
        wages               => 'invalid',
        wages_for           => 'month',
        hours               => 40,
        hours_by            => 'week',
        is_at_office        => 1,
        contract_type       => 'clt',
        required_attributes => 'Moose,DBIx::Class,Ser pró-ativo',
        desired_attributes  => 'jQuery,HTML5',
    }, 'invalid wages');

    _submit_ok({
        status              => 'active',
        title               => 'Test job title 1',
        description         => 'Test job desc 1',
        phone               => '(11) 91234-5676',
        email               => 'abcd@andre.com',
        vacancies           => '1',
        wages               => 'R$ 1.321.456,56',
        wages_for           => 'month',
        hours               => 40,
        hours_by            => 'week',
        is_at_office        => 1,
        contract_type       => 'clt',
        required_attributes => 'Moose,Ser pró-ativo',
        desired_attributes  => 'jQuery,HTML5,Catalyst',
    }, 'submit valid form');

    like(get_job()->wages, qr{^R\$\s*1.321.456,56$}, 'job was updated');
    is(get_max_id(), $job_to_be_updated, 'no job was inserted');

    is_deeply(
        {
            map { ( $_->attribute => $_->required_or_desired ) }
              get_job()->attributes->all
        },
        {
            'Moose'         => 'required',
            'Ser pró-ativo' => 'required',
            'Catalyst'      => 'desired',
            'jQuery'        => 'desired',
            'HTML5'         => 'desired',
        },
        'attributes are correctly set in the db'
    );

    $t->auth->logout();
}

{
    no warnings qw/once redefine/;
    local *Catalyst::Log::warn = sub { 1 };
    is($t->db->resultset('Job')->count({ id => $job_to_be_updated }), 1, 'job exists');
    ok($m->delete("/account/job/$job_to_be_updated"), 'DELETE request');
    is($m->status, 302, 'HTTP status code is correct');
    is($t->db->resultset('Job')->count({ id => $job_to_be_updated }), 1, 'job still exists');

    $t->auth->login_ok('user2-c1');
    is($t->db->resultset('Job')->count({ id => $job_to_be_updated }), 1, 'job exists');
    ok($m->delete("/account/job/$job_to_be_updated"), 'DELETE request');
    is($m->status, 403, 'HTTP status code is correct');
    is($t->db->resultset('Job')->count({ id => $job_to_be_updated }), 1, 'job still exists');
    $t->auth->logout();

    $t->auth->login_ok('user1-c2');
    is($t->db->resultset('Job')->count({ id => $job_to_be_updated }), 1, 'job exists');
    ok($m->delete("/account/job/$job_to_be_updated"), 'DELETE request');
    is($m->status, 204, 'HTTP status code is correct');
    is($t->db->resultset('Job')->count({ id => $job_to_be_updated }), 0, 'job deleted');
    $t->auth->logout();
}

sub _submit_ok {
    my ($data, $msg) = @_;

    $m->submit_form_ok({
        form_id => 'jobs_form',
        fields => {
            map { ( 'job.create_or_update.' . $_, $data->{$_} ) } keys %$data
        },
    }, $msg);
}

sub _values_ok {
    my ($data, $prefix_msg) = @_;

    $prefix_msg = "($prefix_msg) " if $prefix_msg;
    $prefix_msg ||= '';
    my $form = $m->form_id('jobs_form');

    while (my ($k, $v) = each %$data) {
        my $msg = qq|${prefix_msg}`$k` is set correctly in the form|;
        if ($k =~ /_attributes$/) {
            is_deeply(
                [ sort split /,/, $form->value('job.create_or_update.' . $k) ],
                [ sort split /,/, $v ],
                $msg
            );
        }
        elsif (!$v) {
            ok(!$form->value('job.create_or_update.' . $k), $msg);
        }
        elsif (ref $v and ref $v eq 'Regexp') {
            like($form->value('job.create_or_update.' . $k), $v, $msg);
        }
        else {
            is($form->value('job.create_or_update.' . $k), $v, $msg);
        }
    }
}

done_testing();
