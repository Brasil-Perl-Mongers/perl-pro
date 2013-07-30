package PerlPro::Schema::ResultSet::User;

use Moose;
use namespace::autoclean;

extends 'DBIx::Class::ResultSet';
with 'PerlPro::Role::Verification';

use MooseX::Types::Email qw/EmailAddress/;
use MooseX::Types::Moose qw/Str/;
use HTML::Entities ();

use Data::Verifier;

sub _build_verifier_scope_name { 'user' }

sub verifiers_specs {
    my $self = shift;

    return {
        register => Data::Verifier->new(
            profile => {
                company => { required => 1, type => Str },
                name    => { required => 1, type => Str },
                email   => {
                    required   => 1,
                    type       => EmailAddress,
                    post_check => sub {
                        my $s = shift;
                        my $email_rs = $self->result_source->related_source('emails')->resultset;
                        my $count = $email_rs->count({ email => $s->get_value('email') });
                        return $count == 0;
                    }
                },
                login => {
                    required   => 1,
                    type       => Str,
                    post_check => sub {
                        my $s = shift;
                        my $count = $self->count({ login => $s->get_value('login') });
                        return $count == 0;
                    }
                },
                password         => { required => 1, type => Str },
                confirm_password => {
                    required   => 1,
                    type       => Str,
                    post_check => sub {
                        my $s = shift;

                        my $p1 = $s->get_value('password');
                        my $p2 = $s->get_value('confirm_password');

                        if ( $p1 ne $p2 ) {
                            die 'passwords are not equal';
                        }

                        return 1;
                    },
                },
            },
            filters => [
                sub { HTML::Entities::encode_entities( $_[0] ) }
            ],
        ),
    };
}

sub action_specs {
    my $self = shift;
    return {
        register => sub {
            my %values = shift->valid_values;

            my $company = delete $values{company};
            my $email = delete $values{email};

            my $row = $self->create(\%values);

            $row->add_to_companies({ company => $company });
            $row->add_to_emails({ email => $email, is_main_address => 1 });

            return $row;
        },
    };
}

__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;
