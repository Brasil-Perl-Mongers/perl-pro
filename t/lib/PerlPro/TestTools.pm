package PerlPro::TestTools;

$ENV{PERLPRO_WEB_CONFIG_LOCAL_SUFFIX} = 'testing';

use Moose;
use FindBin '$Bin';
use PerlPro::TestTools::Mech;
use namespace::autoclean;

has app => (
    lazy    => 1,
    is      => 'ro',
    default => sub {
        require PerlPro::Web;
        return PerlPro::Web->new;
    },
);

has db => (
    lazy    => 1,
    is      => 'ro',
    default => sub {
        shift->app->model('DB');
    }
);

has mech => (
    isa     => 'PerlPro::TestTools::Mech',
    is      => 'ro',
    lazy    => 1,
    default => sub { my $s = shift; PerlPro::TestTools::Mech->new },
);


sub require_fixtures {
    my ($self) = @_;

    return if $self->fixtures_in_db;

    my $db = $self->db;

    $db->resultset('Role')->populate([
        ['role_name'],
        ['site-admin'],
        ['site-manage-all-companies'],
        ['company-manage-jobs'],
        ['company-manage-profile'],
        ['company-manage-admin'],
        ['company-basic'],
    ]);

    $db->resultset('Company')->populate([
        [ 'name_in_url', 'name', 'description' ],
        ['company1', 'Company One',   'Desc of company one'],
        ['company2', 'Company Two',   'Desc of company two'],
        ['company3', 'Company Three', 'Desc of company three'],
    ]);

    $db->resultset('CompanyEmail')->populate([
        [ 'company', 'email', 'is_main_address' ],
        ['company1', 'a@perlpro.com.br', 1],
        ['company1', 'b@perlpro.com.br', 0],
        ['company2', 'c@perlpro.com.br', 1],
        ['company3', 'd@perlpro.com.br', 1],
    ]);

    $db->resultset('CompanyPhone')->populate([
        [ 'company', 'phone', 'is_main_phone' ],
        ['company1', '1234-5678', 1],
        ['company2', '5678-1234', 1],
        ['company3', '1235-4678', 1],
    ]);

    $db->resultset('CompanyWebsite')->populate([
        [ 'company', 'url', 'is_main_website' ],
        ['company1', 'http://company1.com', 1],
        ['company2', 'http://company2.com', 1],
        ['company3', 'http://company3.com', 1],
    ]);

    $db->resultset('User')->populate([
        ['login', 'password', 'name'],
        ['user1-c1', '-', 'User one C1'],
        ['user2-c1', '-', 'User two C1'],
        ['user1-c2', '-', 'User one C2'],
        ['user1-c3', '-', 'User one C3'],
    ]);

    $db->resultset('UserRole')->populate([
        [ 'user', 'role' ],
        ['user1-c1', 'company-basic'],
        ['user1-c1', 'company-manage-jobs'],
        ['user1-c1', 'company-manage-profile'],
        ['user1-c1', 'company-manage-admin'],
        ['user2-c1', 'company-basic'],
        ['user1-c2', 'company-basic'],
        ['user1-c2', 'company-manage-jobs'],
        ['user1-c2', 'company-manage-profile'],
        ['user1-c2', 'company-manage-admin'],
        ['user1-c3', 'company-basic'],
        ['user1-c3', 'company-manage-jobs'],
        ['user1-c3', 'company-manage-profile'],
        ['user1-c3', 'company-manage-admin'],
    ]);

    $db->resultset('UserCompany')->populate([
        [ 'user', 'company' ],
        ['user1-c1', 'company1'],
        ['user2-c1', 'company1'],
        ['user1-c2', 'company2'],
        ['user1-c3', 'company3'],
    ]);

    $db->resultset('Job')->populate([
        [ 'company', 'title', 'description', 'salary', 'location' ],
        ['company1', 'Catalyst Developer',  'We need a good Catalyst developer',  10000.00, 'Anywhere'],
        ['company2', 'Database analyst',    'We need a good DB analyst',          5000.00, 'Anywhere'],
        ['company3', 'Front-end Developer', 'We need a good front-end developer', 1000.00, 'Anywhere'],
    ]);

    open(my $lock,'>', "$Bin/.lock-fixtures") or die "Can't create lock: $!";
    close($lock);

    return;
}

sub fixtures_in_db {
    my ($self) = @_;

    return -e "$Bin/.lock-fixtures";
}

sub clear_fixtures {
    my ($self) = @_;

    return if !$self->fixtures_in_db;

    my $db = $self->db;

    $db->resultset('Role')->find($_)->delete
      for (
        'site-admin',           'site-manage-all-companies',
        'company-manage-jobs',  'company-manage-profile',
        'company-manage-admin', 'company-basic',
      );

    $db->resultset('Company')->find($_)->delete
      for (qw/company1 company2 company3/);

    $db->resultset('User')->find($_)->delete
      for (qw/user1-c1 user2-c1 user1-c2 user1-c3/);

    unlink "$Bin/.lock-fixtures";

    return;
}

__PACKAGE__->meta->make_immutable;

1;
