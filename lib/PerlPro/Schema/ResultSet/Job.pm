package PerlPro::Schema::ResultSet::Job;

use Moose;
use namespace::autoclean;

extends 'DBIx::Class::ResultSet';
with 'PerlPro::Role::Verification';

use MooseX::Types::Email qw/EmailAddress/;
use MooseX::Types::Moose qw/Int Str Num ArrayRef Bool/;
use PerlPro::Types::Contract qw/ContractType ContractHours/;

use Data::Verifier;

sub _build_verifier_scope_name { 'job' }

sub verifiers_specs {
    my $self = shift;

    return {
        create => Data::Verifier->new(
            profile => {
                company       => { required => 1, type => Str },
                title         => { required => 1, type => Str },
                description   => { required => 1, type => Str },
                salary        => {
                    required => 1,
                    type     => Num,
                    coercion => \&_real_to_float,
                },
                phone               => { required => 0, type => Str },
                email               => { required => 0, type => EmailAddress },
                vacancies           => { required => 0, type => Int },
                contract_type       => { required => 1, type => ContractType },
                contract_hours      => { required => 1, type => ContractHours },
                contract_duration   => { required => 0, type => Str }, # TODO: DateTime?
                is_at_office        => { required => 0, type => Bool },
                location            => { required => 1, type => Str },
                status              => { required => 1, type => Str },
                desired_attributes  => { required => 0, type => ArrayRef[Str] },
                required_attributes => { required => 0, type => ArrayRef[Str] },
            }
        ),
        update => Data::Verifier->new(
            profile => {
                id            => { required => 1, type => Int },
                company       => { required => 1, type => Str },
                title         => { required => 1, type => Str },
                description   => { required => 1, type => Str },
                salary        => {
                    required => 1,
                    type     => Num,
                    coercion => \&_real_to_float,
                },
                phone               => { required => 0, type => Str },
                email               => { required => 0, type => EmailAddress },
                vacancies           => { required => 0, type => Int },
                contract_type       => { required => 1, type => ContractType },
                contract_hours      => { required => 1, type => ContractHours },
                contract_duration   => { required => 0, type => Str }, # TODO: DateTime?
                is_at_office        => { required => 0, type => Bool },
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
            my %row_values;
            for (qw/company title description salary phone email vacancies contract_type contract_hours contract_duration location status/) {
                $row_values{$_} = $values{$_} if $values{$_};
            }
            $row_values{is_telecommute} = !$values{is_at_office};

            my $row = $self->create(\%row_values);

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

            my %row_values;
            for (qw/company title description salary phone email vacancies contract_type contract_hours contract_duration location status/) {
                $row_values{$_} = $values{$_} if $values{$_};
            }
            $row_values{is_telecommute} = !$values{is_at_office};

            $row->update(\%row_values);

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

sub get_recent_jobs {
    my $self = shift;
    my @result;

    my $jobs = $self->search({
        status => 'active',
    }, {
        order_by => { -desc => 'created_at' },
        rows => 6,
    });

    for my $j ($jobs->all) {
        my $c = $j->company;
        push @result, {
            title => $j->title,
            company_url => $c->name_in_url,
            company_name => $c->name,
            location => $j->location,
            id => $j->id,
        };
    }

    return \@result;
}

sub get_job_and_company_by_job_id {
    my ( $self, $id ) = @_;

    my $job = $self->find($id);

    return unless $job;

    my $company = $job->company;

    my $website_obj = $company->company_websites->search({}, {
        order_by => { -desc => 'is_main_website' }
    })->first;
    my $phone_obj = $company->company_phones->search({}, {
        order_by => { -desc => 'is_main_phone' }
    })->first;
    my $email_obj = $company->company_emails->search({}, {
        order_by => { -desc => 'is_main_address' }
    })->first;
    my $location_obj = $company->company_locations->search({}, {
        order_by => { -desc => 'is_main_address' }
    })->first;

    my $url   = $website_obj ? $website_obj->url : '';
    my $email = $email_obj   ? $email_obj->email : '';
    my $phone = $phone_obj   ? $phone_obj->phone : '';

    my $formatted_address = $location_obj
                          ? ( $location_obj->address . ", "
                            . $location_obj->city    . " - "
                            . $location_obj->state )
                          : ''
                          ;

    my @required = $job->attributes->search({ required_or_desired => 'required' })->all;
    my @desired  = $job->attributes->search({ required_or_desired => 'desired' })->all;

    my $other_jobs = $company->jobs->search({
        status => 'active', # TODO: promoted first
        id => { '!=', $id },
    }, {
        order_by => { -desc => 'created_at' },
        rows => 4,
    });

    return {
        job => {
            id                  => $id,
            title               => $job->title,
            salary              => $job->salary,
            location            => $job->location,
            description         => $job->description,
            required_attributes => { map { $_->id, $_->attribute } @required },
            desired_attributes  => { map { $_->id, $_->attribute } @desired  },
        },
        company => {
            name_in_url       => $company->name_in_url,
            name              => $company->name,
            description       => $company->description,
            website           => $url,
            email             => $email,
            phone             => $phone,
            formatted_address => $formatted_address,
            other_jobs        => [ $other_jobs->all ],
        },
    };
}

sub _real_to_float {
    my $value = shift;
    $value =~ s/R\$//;
    $value =~ s/\s*//g;
    $value =~ s/,/|COMMA|/;
    $value =~ s/\./,/g;
    $value =~ s/|COMMA|/\./;
    return 0 + sprintf("%.2f", $value);
}

__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;
