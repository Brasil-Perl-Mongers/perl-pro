use FindBin '$Bin';
use lib "$Bin/lib";

use PerlPro::TestTools;
use DateTime;

my $t = PerlPro::TestTools->new( requires_fixtures => 0 );
$t->clear_fixtures; # we want only our own fixtures in the DB

my $db      = $t->db;
my $comp_rs = $db->resultset('Company');
my $job_rs  = $db->resultset('Job');

my $first_job_id = 20;
my $last_job_id  = $first_job_id + 500;
my $companies    = [
    [ 'gs_company_1',  40, { address => 'Street One, 23',   city => 'Bogus City 1', state => 'XX', country => 'Brazil' } ],
    [ 'gs_company_2',  70, { address => 'Street Two, 49',   city => 'Bogus City 2', state => 'XY', country => 'Brazil' } ],
    [ 'gs_company_3',  20, { address => 'Street Three, 50', city => 'Bogus City 3', state => 'YY', country => 'Brazil' } ],
    [ 'gs_company_4',  80, { address => 'Street One, 11',   city => 'Bogus City 4', state => 'ZY', country => 'Brazil' } ],
    [ 'gs_company_5', 100, { address => 'Street Two, 22',   city => 'Bogus City 5', state => 'ZX', country => 'Brazil' } ],
    [ 'gs_company_6', 100, { address => 'Street Three, 33', city => 'Bogus City 6', state => 'ZZ', country => 'Brazil' } ],
    [ 'gs_company_7',  90, { address => 'Street One, 01',   city => 'Bogus City 7', state => 'YX', country => 'Brazil' } ],
];
my @salaries = map { $_ * 1000 } 1..10;
my @ctypes   = ('clt', 'pj', 'internship', 'freelance', 'no-contract');

sub install_fixtures {
    my $current_job_id = $first_job_id;

    for (@$companies) {
        my ($name, $count, $address) = @$_;

        my $fancy = $name;
        $fancy =~ s/_/ /g;

        my $comp = $comp_rs->create({
            name_in_url => $name,
            name        => $fancy,
            description => "Desc of $fancy",
        });

        my $first = $current_job_id + 1;
        my $last  = $first + $count - 1;

        for ($first .. $last) {
            my $job = $comp->add_to_jobs({
                id            => $_,
                title         => "Job $_",
                description   => "Desc of job $_",
                wages         => $salaries[$_ % 10],
                contract_type => $ctypes[$_ % 5],
            });
            $job->create_related('job_location', $address);
        }

        $current_job_id = $last;
    }
}

sub uninstall_fixtures {
    for (@$companies) {
        my ($name, $count, $address) = @$_;
        my $c = $comp_rs->find($name);
        $c->delete if $c;
    }
}

uninstall_fixtures();
install_fixtures();

{
    ok(my $s = $job_rs->grid_search(), 'empty search');
    is_deeply(
        $s->{pager},
        {
            current_page     => 1,
            total_entries    => 500,
            entries_per_page => 10,
            first_page       => 1,
            last_page        => 50,
            first_on_page    => 1,
            last_on_page     => 10,
        },
        'the pager is correct',
    );
}

{
    ok(my $s = $job_rs->grid_search(page => 5, rows => 50), 'define page and rows');
    is_deeply(
        $s->{pager},
        {
            current_page     => 5,
            total_entries    => 500,
            entries_per_page => 50,
            first_page       => 1,
            last_page        => 10,
            first_on_page    => 201,
            last_on_page     => 250,
        },
        'the pager is correct',
    );
}

{
    ok(my $s = $job_rs->grid_search(page => 2, rows => 50, filters => { companies => [ qw/gs_company_3 gs_company_4 gs_company_5 gs_company_6/ ] }), 'search by companies');
    is_deeply(
        $s->{pager},
        {
            current_page     => 2,
            total_entries    => 300,
            entries_per_page => 50,
            first_page       => 1,
            last_page        => 6,
            first_on_page    => 51,
            last_on_page     => 100,
        },
        'the pager is correct',
    );
    for (@{ $s->{items} }) {
        ok(
            $_->{company_name} eq 'gs company 3'
              || $_->{company_name} eq 'gs company 4'
              || $_->{company_name} eq 'gs company 5'
              || $_->{company_name} eq 'gs company 6',
            "company name for item $_->{id} of search by companies is correct"
        );
    }
}

{
    ok(my $s = $job_rs->grid_search(page => 1, rows => 5, filters => { term => '231' }), 'search by term');
    is_deeply(
        $s->{pager},
        {
            current_page     => 1,
            total_entries    => 1,
            entries_per_page => 5,
            first_page       => 1,
            last_page        => 1,
            first_on_page    => 1,
            last_on_page     => 1,
        },
        'the pager is correct',
    );
    is( scalar @{ $s->{items} }, 1, 'only one item returned' );
    my $item = $s->{items}->[0];
    is( $item->{company_name}, 'gs company 5', 'company name is correct');
    is( $item->{company}, 'gs_company_5', 'company is correct');
    is( $item->{created_at}, DateTime->today->dmy('/'), 'date is correct');
    is( $item->{id}, 231, 'id is correct');
    is( $item->{title}, 'Job 231', 'title is correct');
    is( $item->{description}, 'Desc of job 231', 'description is correct');
    like( $item->{salary}, qr{R\$\s*2\.000,00}, 'the salary is correct');
    ok(!$item->{phone}, 'no phone');
    ok(!$item->{email}, 'no email');
    is( $item->{vacancies},  1, 'one vacancy');
    is( $item->{contract_type}, 'pj', 'contract is for pj');
    ok(!$item->{is_telecommute}, q{it's not telecommute});
    is( $item->{city}, 'Bogus City 5', 'the city is correct');
}

{
    ok(my $s = $job_rs->grid_search(rows => 100, filters => { salary_to => '2000' }), 'search by salary (to)');
    is_deeply(
        $s->{pager},
        {
            current_page     => 1,
            total_entries    => 100,
            entries_per_page => 100,
            first_page       => 1,
            last_page        => 1,
            first_on_page    => 1,
            last_on_page     => 100,
        },
        'the pager is correct',
    );

    for ( @{ $s->{items} } ) {
        like( $_->{salary}, qr{R\$\s*[12]\.000,00}, qq|the salary for $_->{id} is correct|);
    }
    is( scalar @{ $s->{items} }, 100, 'the item count is correct' );
}

{
    ok(my $s = $job_rs->grid_search(rows => 100, filters => { salary_from => '9000' }), 'search by salary (from)');
    is_deeply(
        $s->{pager},
        {
            current_page     => 1,
            total_entries    => 100,
            entries_per_page => 100,
            first_page       => 1,
            last_page        => 1,
            first_on_page    => 1,
            last_on_page     => 100,
        },
        'the pager is correct',
    );

    for ( @{ $s->{items} } ) {
        like( $_->{salary}, qr{R\$\s*(9|10)\.000,00}, qq|the salary for $_->{id} is correct|);
    }
    is( scalar @{ $s->{items} }, 100, 'the item count is correct' );
}

{
    ok(my $s = $job_rs->grid_search(rows => 50, filters => { salary_from => '3000', salary_to => '3000' }), 'search by salary (from and to)');
    is_deeply(
        $s->{pager},
        {
            current_page     => 1,
            total_entries    => 50,
            entries_per_page => 50,
            first_page       => 1,
            last_page        => 1,
            first_on_page    => 1,
            last_on_page     => 50,
        },
        'the pager is correct',
    );

    for ( @{ $s->{items} } ) {
        like( $_->{salary}, qr{R\$\s*3\.000,00}, qq|the salary for $_->{id} is correct|);
    }
    is( scalar @{ $s->{items} }, 50, 'the item count is correct' );
}

{
    ok(my $s = $job_rs->grid_search(rows => 200, filters => { contract_type => [qw/pj clt/] }), 'search by contract type');
    is_deeply(
        $s->{pager},
        {
            current_page     => 1,
            total_entries    => 200,
            entries_per_page => 200,
            first_page       => 1,
            last_page        => 1,
            first_on_page    => 1,
            last_on_page     => 200,
        },
        'the pager is correct',
    );

    for ( @{ $s->{items} } ) {
        like( $_->{contract_type}, qr{clt|pj}, qq|the salary for $_->{id} is correct|);
    }
    is( scalar @{ $s->{items} }, 200, 'the item count is correct' );
}

# TODO: test grid sorting
# TODO: test search by location
# TODO: test fixtures with attributes
# TODO: test fixtures with hours, hours_by

uninstall_fixtures();
done_testing();
