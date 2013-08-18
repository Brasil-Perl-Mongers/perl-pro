package PerlPro::Schema::ResultSet::Job;

use Moose;
use namespace::autoclean;

extends 'DBIx::Class::ResultSet';
with 'PerlPro::Role::Verification';

use MooseX::Types::Moose qw/Int Str ArrayRef/;

use Data::Verifier;

sub _build_verifier_scope_name { 'job' }

sub verifiers_specs {
    my $self = shift;

    return {
        create => Data::Verifier->new(
            profile => {
                company             => { required => 1, type => Str },
                title               => { required => 1, type => Str },
                description         => { required => 1, type => Str },
                salary              => { required => 1, type => Str },
                location            => { required => 1, type => Str },
                status              => { required => 1, type => Str },
                desired_attributes  => { required => 0, type => ArrayRef[Str] },
                required_attributes => { required => 0, type => ArrayRef[Str] },
            }
        ),
        update => Data::Verifier->new(
            profile => {
                id                  => { required => 1, type => Int },
                company             => { required => 1, type => Str },
                title               => { required => 1, type => Str },
                description         => { required => 1, type => Str },
                salary              => { required => 1, type => Str },
                location            => { required => 1, type => Str },
                status              => { required => 1, type => Str },
                desired_attributes  => { required => 0, type => ArrayRef[Str] },
                required_attributes => { required => 0, type => ArrayRef[Str] },
            }
        ),
    };
}

sub action_specs {
    my $self = shift;
    return {
        create => sub {
            my %values = shift->valid_values;
            my $row = $self->create({
                company     => $values{company},
                title       => $values{title},
                description => $values{description},
                salary      => $values{salary},
                location    => $values{location},
                status      => $values{status},
            });

            for my $type (qw/required desired/) {
                for my $attr (@{ $values{"${type}_attributes"} }) {
                    $row->add_to_attributes({
                        required_or_desired => $type,
                        attribute           => $attr,
                    });
                }
            }

            return $row;
        },
        update => sub {
            my %values = shift->valid_values;

            my $row = $self->find($values{id});

            $row->attributes->delete;

            $row->update({
                company     => $values{company},
                title       => $values{title},
                description => $values{description},
                salary      => $values{salary},
                location    => $values{location},
                status      => $values{status},
            });

            for my $type (qw/required desired/) {
                for my $attr (@{ $values{"${type}_attributes"} }) {
                    $row->add_to_attributes({
                        required_or_desired => $type,
                        attribute           => $attr,
                    });
                }
            }

            return $row;
        },
    };
}

__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;
