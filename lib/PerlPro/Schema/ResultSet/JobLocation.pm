package PerlPro::Schema::ResultSet::JobLocation;

use Moose;
use namespace::autoclean;

extends 'DBIx::Class::ResultSet';
with 'PerlPro::Role::Verification';

use MooseX::Types::Moose qw/Int Str/;

use Data::Verifier;

sub _build_verifier_scope_name { 'job_location' }

sub verifiers_specs {
    my $self = shift;

    return {
        create => Data::Verifier->new(
            profile => {
                job     => { required => 1, type => Int },
                lat     => { required => 0, type => Int },
                lng     => { required => 0, type => Int },
                address => { required => 1, type => Str },
                city    => { required => 1, type => Str },
                state   => { required => 1, type => Str },
                country => { required => 1, type => Str },
            }
        ),
    };
}

sub action_specs {
    my $self = shift;
    return {
        create => sub {
            my %values = shift->valid_values;

            my $lat = delete($values{lat});
            my $lng = delete($values{lng});

            if ($lat && $lng) {
                $values{latlng} = "($lat,$lng)";
            }

            my $row = $self->create(\%values);

            return $row;
        },
    };
}

__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;
