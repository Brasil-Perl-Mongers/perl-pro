package PerlPro::TestTools::Auth;
use Moose;
use Test::More;
use namespace::autoclean;

has mech => (
    is       => 'ro',
    isa      => 'Test::WWW::Mechanize',
    weak_ref => 1,
);

has page => (
    is  => 'ro',
    isa => 'Str'
);

has _credentials => (
    is  => 'ro',
    isa => 'HashRef',
    default => sub { +{
        'user1-c1', 'u1-123',
        'user2-c1', 'u2-123',
        'user1-c2', 'u3-123',
        'user1-c3', 'u4-123',
    } },
);

sub as {
    my ( $self, $login, $password ) = @_;
    my $mech = $self->mech;
    my $page = $self->page;

    $password ||= $self->_credentials->{$login};

    $mech->get_ok($page);
    my $number = $self->_find_first_login_form();
    $mech->submit_form_ok({
        form_number => $number,
        fields      => {
            'login'    => $login,
            'password' => $password,
        }
    }, 'login form successfully submitted');
}

sub login_ok {
    my ( $self, $login, $password ) = @_;
    my $page = $self->page;
    my $info;

    no warnings 'redefine';
    local *Catalyst::Log::info = sub { $info = $_[1] };
    $self->as($login, $password);
    is($info, "AUTHENTICATED USER $login", "$login successfully logged in.");

    $self->mech->base_like(qr{$page});
}

sub login_not_ok {
    my ( $self, $login, $password ) = @_;
    my $page = $self->page;
    my $info;

    no warnings 'redefine';
    local *Catalyst::Log::info = sub { $info = $_[1] };
    $self->as($login, $password);
    is($info, "COULD NOT AUTHENTICATE USER $login", "$login couldn't log in (as expected).");

    $self->mech->base_like(qr{/account/login});
}

sub logout {
    my ( $self ) = @_;
    my $mech = $self->mech;
    $mech->get_ok("/account/logout");
}

sub _find_first_login_form {
    my ( $self ) = @_;

    my $i = 1;

    for my $f ($self->mech->forms) {
        if ($f->action =~ m[/account/login]) {
            return $i;
        }
        $i++;
    }

    fail('could not find login form');

    return -1;
}

__PACKAGE__->meta->make_immutable;

1;
