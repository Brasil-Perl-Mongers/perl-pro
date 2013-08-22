use FindBin '$Bin';
use lib "$Bin/lib";

use PerlPro::TestTools;
use PerlPro::Web::Controller::Company::Job;

my $t = PerlPro::TestTools->new( current_page => '/account/my_jobs' );
my $m = $t->mech;
my $page = $t->current_page;
my $job_to_be_updated = 0;
sub get_job { $t->db->resultset('Job')->find($job_to_be_updated) }

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
    sub get_max_id {
        return $t->db->resultset('Company')->find('company2')->jobs->search({}, { order_by => { -desc => 'id' } })->first->id;
    }

    my $max_id = get_max_id();

    $t->auth->login_ok('user1-c2');
    $m->get_ok('/account/job/new');

    my $form = $m->form_id( 'jobs_form' );
    ok(!$form->value('job.create_or_update.id'), 'id is set correctly in the form');
    is($form->value('job.create_or_update.title'), '', 'title is set correctly in the form');
    is($form->value('job.create_or_update.description'), '', 'description is set correctly in the form');
    is($form->value('job.create_or_update.salary'), '', 'salary is set correctly in the form');
    is($form->value('job.create_or_update.location'), '', 'location is set correctly in the form');
    is($form->value('job.create_or_update.phone'), '', 'phone is set correctly in the form');
    is($form->value('job.create_or_update.email'), '', 'email is set correctly in the form');
    is($form->value('job.create_or_update.vacancies'), '1', 'vacancies is set correctly in the form');
    ok(!$form->value('job.create_or_update.is_at_office'), '`is at office` is set correctly in the form');
    is($form->value('job.create_or_update.status'), 'active', 'status is set correctly in the form');
    ok(!$form->value('job.create_or_update.required_attributes'), 'required_attributes are set correctly in the form');
    ok(!$form->value('job.create_or_update.desired_attributes'), 'desired_attributes are set correctly in the form');

# TODO:
#    is($form->value('job.create_or_update.contract_duration'), '', 'contract duration is set correctly in the form');
#    is($form->value('job.create_or_update.contract_type'), 'other', 'contract type is set correctly in the form');

    $m->submit_form_ok({
        form_id => 'jobs_form',
        fields => {
            'job.create_or_update.title'               => 'Test job title 1',
            'job.create_or_update.description'         => 'Test job desc 1',
            'job.create_or_update.salary'              => 'R$ 1.000.000,56',  # 2 dots, 1 comma
            'job.create_or_update.location'            => 'Test location 1',
            'job.create_or_update.phone'               => '(11) 91234-5676',
            'job.create_or_update.email'               => 'abcd',             # invalid
            'job.create_or_update.vacancies'           => '1',
            'job.create_or_update.contract_type'       => 'clt',
            'job.create_or_update.is_at_office'        => 1,
            'job.create_or_update.status'              => 'active',
            'job.create_or_update.required_attributes' => 'Moose,DBIx::Class,Ser pró-ativo',
            'job.create_or_update.desired_attributes'  => 'jQuery,HTML5',
        },
    });

    is(get_max_id(), $max_id, 'no job was inserted');

    $form = $m->form_id( 'jobs_form' );
    ok(!$form->value('job.create_or_update.id'), '(invalid e-mail) id is set correctly in the form');
    is($form->value('job.create_or_update.title'), 'Test job title 1', '(invalid e-mail) title is set correctly in the form');
    is($form->value('job.create_or_update.description'), 'Test job desc 1', '(invalid e-mail) description is set correctly in the form');
    is($form->value('job.create_or_update.salary'), 'R$ 1.000.000,56', '(invalid e-mail) salary is set correctly in the form');
    is($form->value('job.create_or_update.location'), 'Test location 1', '(invalid e-mail) location is set correctly in the form');
    is($form->value('job.create_or_update.phone'), '(11) 91234-5676', '(invalid e-mail) phone is set correctly in the form');
    is($form->value('job.create_or_update.email'), 'abcd', '(invalid e-mail) email is set correctly in the form');
    is($form->value('job.create_or_update.vacancies'), '1', '(invalid e-mail) vacancies is set correctly in the form');
    is($form->value('job.create_or_update.contract_type'), 'clt', '(invalid e-mail) contract type is set correctly in the form');
    is($form->value('job.create_or_update.is_at_office'), 1, '(invalid e-mail) `is at office` is set correctly in the form');
    is($form->value('job.create_or_update.status'), 'active', '(invalid e-mail) status is set correctly in the form');
    is($form->value('job.create_or_update.required_attributes'), 'Moose,DBIx::Class,Ser pró-ativo', '(invalid e-mail) required_attributes are set correctly in the form');
    is($form->value('job.create_or_update.desired_attributes'), 'jQuery,HTML5', '(invalid e-mail) desired_attributes are set correctly in the form');

    $m->submit_form_ok({
        form_id => 'jobs_form',
        fields => {
            'job.create_or_update.title'               => '',                 # required
            'job.create_or_update.description'         => 'Test job desc 1',
            'job.create_or_update.salary'              => 'R$ 1.000.000,56',  # 2 dots, 1 comma
            'job.create_or_update.location'            => 'Test location 1',
            'job.create_or_update.phone'               => '(11) 91234-5676',
            'job.create_or_update.email'               => 'abcd@andre.com',
            'job.create_or_update.vacancies'           => '1',
            'job.create_or_update.contract_type'       => 'clt',
            'job.create_or_update.is_at_office'        => 1,
            'job.create_or_update.status'              => 'active',
            'job.create_or_update.required_attributes' => 'Moose,DBIx::Class,Ser pró-ativo',
            'job.create_or_update.desired_attributes'  => 'jQuery,HTML5',
        },
    });

    is(get_max_id(), $max_id, 'no job was inserted');

    $form = $m->form_id( 'jobs_form' );
    ok(!$form->value('job.create_or_update.id'), '(missing title) id is set correctly in the form');
    is($form->value('job.create_or_update.title'), '', '(missing title) title is set correctly in the form');
    is($form->value('job.create_or_update.description'), 'Test job desc 1', '(missing title) description is set correctly in the form');
    is($form->value('job.create_or_update.salary'), 'R$ 1.000.000,56', '(missing title) salary is set correctly in the form');
    is($form->value('job.create_or_update.location'), 'Test location 1', '(missing title) location is set correctly in the form');
    is($form->value('job.create_or_update.phone'), '(11) 91234-5676', '(missing title) phone is set correctly in the form');
    is($form->value('job.create_or_update.email'), 'abcd@andre.com', '(missing title) email is set correctly in the form');
    is($form->value('job.create_or_update.vacancies'), '1', '(missing title) vacancies is set correctly in the form');
    is($form->value('job.create_or_update.contract_type'), 'clt', '(missing title) contract type is set correctly in the form');
    is($form->value('job.create_or_update.is_at_office'), 1, '(missing title) `is at office` is set correctly in the form');
    is($form->value('job.create_or_update.status'), 'active', '(missing title) status is set correctly in the form');
    is($form->value('job.create_or_update.required_attributes'), 'Moose,DBIx::Class,Ser pró-ativo', '(missing title) required_attributes are set correctly in the form');
    is($form->value('job.create_or_update.desired_attributes'), 'jQuery,HTML5', '(missing title) desired_attributes are set correctly in the form');

    $m->submit_form_ok({
        form_id => 'jobs_form',
        fields => {
            'job.create_or_update.title'               => 'Test job title 1',
            'job.create_or_update.description'         => 'Test job desc 1',
            'job.create_or_update.salary'              => 'R$ 1.000.000,56',  # 2 dots, 1 comma
            'job.create_or_update.location'            => 'Test location 1',
            'job.create_or_update.phone'               => '(11) 91234-5676',
            'job.create_or_update.email'               => 'abcd@andre.com',
            'job.create_or_update.vacancies'           => '1',
            'job.create_or_update.contract_type'       => 'clt',
            'job.create_or_update.is_at_office'        => 1,
            'job.create_or_update.status'              => 'active',
            'job.create_or_update.required_attributes' => 'Moose,DBIx::Class,Ser pró-ativo',
            'job.create_or_update.desired_attributes'  => 'jQuery,HTML5',
        },
    });

    my $new_max = get_max_id();
    cmp_ok($new_max, '>', $max_id, 'a job was created in the db');

    if ($new_max <= $max_id) {
        BAIL_OUT('expected job to be inserted');
    }

    $job_to_be_updated = $new_max;

    is_deeply({
        map {
            ($_->attribute => $_->required_or_desired)
        } get_job()->attributes->all
    }, {
        'Moose' => 'required',
        'DBIx::Class' => 'required',
        'Ser pró-ativo' => 'required',
        'jQuery' => 'desired',
        'HTML5' => 'desired',
    }, 'attributes are correctly set in the db');


    $t->auth->logout();
}

# update job
{
    $t->auth->login_ok('user1-c2');
    $m->get_ok('/account/job/' . $job_to_be_updated);

    my $form = $m->form_id( 'jobs_form' );
    is($form->value('job.create_or_update.id'), $job_to_be_updated, 'id is set correctly in the form');
    is($form->value('job.create_or_update.title'), 'Test job title 1', 'title is set correctly in the form');
    is($form->value('job.create_or_update.description'), 'Test job desc 1', 'description is set correctly in the form');
    like($form->value('job.create_or_update.salary'), qr{^R\$\s*1.000.000,56$}, 'salary is set correctly in the form');
    is($form->value('job.create_or_update.location'), 'Test location 1', 'location is set correctly in the form');
    is($form->value('job.create_or_update.phone'), '(11) 91234-5676', 'phone is set correctly in the form');
    is($form->value('job.create_or_update.email'), 'abcd@andre.com', 'email is set correctly in the form');
    is($form->value('job.create_or_update.vacancies'), '1', 'vacancies is set correctly in the form');
    is($form->value('job.create_or_update.is_at_office'), 1, '`is at office` is set correctly in the form');
    is($form->value('job.create_or_update.status'), 'active', 'status is set correctly in the form');
    is($form->value('job.create_or_update.required_attributes'), 'Moose,DBIx::Class,Ser pró-ativo', 'required_attributes are set correctly in the form');
    is($form->value('job.create_or_update.desired_attributes'), 'jQuery,HTML5', 'desired_attributes are set correctly in the form');

    $m->submit_form(
        form_id => 'jobs_form',
        fields => {
            'job.create_or_update.title'               => 'Test job title 1',
            'job.create_or_update.description'         => 'Test job desc 1',
            'job.create_or_update.salary'              => '',
            'job.create_or_update.location'            => 'Test location 1',
            'job.create_or_update.phone'               => '(11) 91234-5676',
            'job.create_or_update.email'               => 'abcd@andre.com',
            'job.create_or_update.vacancies'           => '1',
            'job.create_or_update.contract_type'       => 'clt',
            'job.create_or_update.is_at_office'        => 1,
            'job.create_or_update.status'              => 'active',
            'job.create_or_update.required_attributes' => 'Moose,DBIx::Class,Ser pró-ativo',
            'job.create_or_update.desired_attributes'  => 'jQuery,HTML5',
        },
    );

    like(get_job()->salary, qr{^R\$\s*1.000.000,56$}, 'job was not updated');

    $form = $m->form_id( 'jobs_form' );
    is($form->value('job.create_or_update.id'), $job_to_be_updated, '(missing salary) id is set correctly in the form');
    is($form->value('job.create_or_update.title'), 'Test job title 1', '(missing salary) title is set correctly in the form');
    is($form->value('job.create_or_update.description'), 'Test job desc 1', '(missing salary) description is set correctly in the form');
    is($form->value('job.create_or_update.salary'), '', '(missing salary) salary is set correctly in the form');
    is($form->value('job.create_or_update.location'), 'Test location 1', '(missing salary) location is set correctly in the form');
    is($form->value('job.create_or_update.phone'), '(11) 91234-5676', '(missing salary) phone is set correctly in the form');
    is($form->value('job.create_or_update.email'), 'abcd@andre.com', '(missing salary) email is set correctly in the form');
    is($form->value('job.create_or_update.vacancies'), '1', '(missing salary) vacancies is set correctly in the form');
    is($form->value('job.create_or_update.contract_type'), 'clt', '(missing salary) contract type is set correctly in the form');
    is($form->value('job.create_or_update.is_at_office'), 1, '(missing salary) `is at office` is set correctly in the form');
    is($form->value('job.create_or_update.status'), 'active', '(missing salary) status is set correctly in the form');
    is($form->value('job.create_or_update.required_attributes'), 'Moose,DBIx::Class,Ser pró-ativo', '(missing salary) required_attributes are set correctly in the form');
    is($form->value('job.create_or_update.desired_attributes'), 'jQuery,HTML5', '(missing salary) desired_attributes are set correctly in the form');

    $m->submit_form(
        form_id => 'jobs_form',
        fields => {
            'job.create_or_update.title'               => 'Test job title 1',
            'job.create_or_update.description'         => 'Test job desc 1',
            'job.create_or_update.salary'              => 'invalid',              # invalid
            'job.create_or_update.location'            => 'Test location 1',
            'job.create_or_update.phone'               => '(11) 91234-5676',
            'job.create_or_update.email'               => 'abcd@andre.com',
            'job.create_or_update.vacancies'           => '1',
            'job.create_or_update.contract_type'       => 'clt',
            'job.create_or_update.is_at_office'        => 1,
            'job.create_or_update.status'              => 'active',
            'job.create_or_update.required_attributes' => 'Moose,DBIx::Class,Ser pró-ativo',
            'job.create_or_update.desired_attributes'  => 'jQuery,HTML5',
        },
    );

    like(get_job()->salary, qr{^R\$\s*1.000.000,56$}, 'job was not updated');

    $form = $m->form_id( 'jobs_form' );
    is($form->value('job.create_or_update.id'), $job_to_be_updated, '(invalid salary) id is set correctly in the form');
    is($form->value('job.create_or_update.title'), 'Test job title 1', '(invalid salary) title is set correctly in the form');
    is($form->value('job.create_or_update.description'), 'Test job desc 1', '(invalid salary) description is set correctly in the form');
    is($form->value('job.create_or_update.salary'), 'invalid', '(invalid salary) salary is set correctly in the form');
    is($form->value('job.create_or_update.location'), 'Test location 1', '(invalid salary) location is set correctly in the form');
    is($form->value('job.create_or_update.phone'), '(11) 91234-5676', '(invalid salary) phone is set correctly in the form');
    is($form->value('job.create_or_update.email'), 'abcd@andre.com', '(invalid salary) email is set correctly in the form');
    is($form->value('job.create_or_update.vacancies'), '1', '(invalid salary) vacancies is set correctly in the form');
    is($form->value('job.create_or_update.contract_type'), 'clt', '(invalid salary) contract type is set correctly in the form');
    is($form->value('job.create_or_update.is_at_office'), 1, '(invalid salary) `is at office` is set correctly in the form');
    is($form->value('job.create_or_update.status'), 'active', '(invalid salary) status is set correctly in the form');
    is($form->value('job.create_or_update.required_attributes'), 'Moose,DBIx::Class,Ser pró-ativo', '(invalid salary) required_attributes are set correctly in the form');
    is($form->value('job.create_or_update.desired_attributes'), 'jQuery,HTML5', '(invalid salary) desired_attributes are set correctly in the form');

    $m->submit_form(
        form_id => 'jobs_form',
        fields => {
            'job.create_or_update.title'               => 'Test job title 1',
            'job.create_or_update.description'         => 'Test job desc 1',
            'job.create_or_update.salary'              => 'R$ 1.321.456,56',
            'job.create_or_update.location'            => 'Test location 1',
            'job.create_or_update.phone'               => '(11) 91234-5676',
            'job.create_or_update.email'               => 'abcd@andre.com',
            'job.create_or_update.vacancies'           => '1',
            'job.create_or_update.contract_type'       => 'clt',
            'job.create_or_update.is_at_office'        => 1,
            'job.create_or_update.status'              => 'active',
            'job.create_or_update.required_attributes' => 'Moose,Ser pró-ativo',
            'job.create_or_update.desired_attributes'  => 'jQuery,HTML5,Catalyst',
        },
    );

    like(get_job()->salary, qr{^R\$\s*1.321.456,56$}, 'job was updated');

    is_deeply({
        map {
            ($_->attribute => $_->required_or_desired)
        } get_job()->attributes->all
    }, {
        'Moose' => 'required',
        'Ser pró-ativo' => 'required',
        'Catalyst' => 'desired',
        'jQuery' => 'desired',
        'HTML5' => 'desired',
    }, 'attributes are correctly set in the db');

    $t->auth->logout();
}

TODO: {
    local $TODO = "not implemented yet";
    $t->db->resultset('Job')->find($job_to_be_updated)->delete;
    fail('remove job');
}

done_testing();
