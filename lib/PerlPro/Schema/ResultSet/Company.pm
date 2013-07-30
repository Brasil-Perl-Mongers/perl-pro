package PerlPro::Schema::ResultSet::Company;

use Moose;
use namespace::autoclean;

extends 'DBIx::Class::ResultSet';
with 'PerlPro::Role::Verification';

use MooseX::Types::Email qw/EmailAddress/;
use MooseX::Types::Moose qw/Str/;
use HTML::Entities ();
use Text::Unaccent::PurePerl ();

use Data::Verifier;

sub _build_verifier_scope_name { 'company' }

sub verifiers_specs {
    my $self = shift;

    return {
        register => Data::Verifier->new(
            profile => {
                name        => { required => 1, type => Str },
                description => { required => 1, type => Str },
                email       => { required => 1, type => EmailAddress },
                phone       => { required => 1, type => Str },
                address     => { required => 1, type => Str },
                city        => { required => 1, type => Str },
                state       => { required => 1, type => Str },
            },
            filters => [
                sub { HTML::Entities::encode_entities( $_[0] ) }
            ],
        )
    };
}

sub action_specs {
    my $self = shift;
    return {
        register => sub {
            my %values = shift->valid_values;

            my $name_in_url = lc Text::Unaccent::PurePerl::unac_string($values{name});
            $name_in_url =~ s/\s+/_/g;
            $name_in_url =~ s/[^a-z_]//g;

            my $row = $self->create({
                name_in_url => $name_in_url,
                name        => $values{name},
                description => $values{description},
            });

            $row->add_to_emails({ email => $values{email}, is_main_address => 1 });
            $row->add_to_phones({ phone => $values{phone}, is_main_phone   => 1 });

            $row->add_to_locations({
                address         => $values{address},
                city            => $values{city},
                state           => $values{state},
                country         => 'Brazil', # later on, it won't be hardcoded
                is_main_address => 1,
            });

            return $row;
        },
    };
}

__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;
