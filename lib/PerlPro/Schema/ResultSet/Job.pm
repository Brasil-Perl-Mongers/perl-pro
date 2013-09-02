package PerlPro::Schema::ResultSet::Job;

use Moose;
use namespace::autoclean;

extends 'DBIx::Class::ResultSet';
with 'PerlPro::Role::Verification';

use MooseX::Types::Email qw/EmailAddress/;
use MooseX::Types::Moose qw/Int Str Bool/;
use PerlPro::Types::Contract qw/ContractType WagesFor HoursBy/;
use PerlPro::Types::Money qw/Money/;
use PerlPro::Types::AttributeArray qw/AttributeArray/;
use Scalar::Util qw/blessed/;

use Data::Verifier;

sub _build_verifier_scope_name { 'job' }

sub verifiers_specs {
    my $self = shift;

    return {
        create_or_update => Data::Verifier->new(
            profile => {
                id                  => { required => 0, type => Int },
                status              => { required => 1, type => Str },
                company             => { required => 1, type => Str },
                title               => { required => 1, type => Str },
                description         => { required => 1, type => Str },
                vacancies           => { required => 0, type => Int },
                phone               => { required => 0, type => Str },
                email               => { required => 0, type => EmailAddress },
                wages               => { required => 1, type => Money },
                wages_for           => { required => 1, type => WagesFor },
                hours               => { required => 1, type => Int },
                hours_by            => { required => 1, type => HoursBy },
                is_at_office        => { required => 0, type => Bool },
                contract_type       => { required => 0, type => ContractType }, # if it's not set, it's "no-contract"
                desired_attributes  => { required => 0, type => AttributeArray, coerce => 1 },
                required_attributes => { required => 0, type => AttributeArray, coerce => 1 },
            }
        ),
    };
}

sub action_specs {
    my $self = shift;
    return {
        create_or_update => sub {
            my %values = shift->valid_values;
            my (%row_values, $row);
            for (qw/status company title description vacancies phone email wages wages_for hours hours_by contract_type/) {
                $row_values{$_} = $values{$_} if $values{$_};
            }
            $row_values{is_telecommute} = $values{is_at_office} ? 0 : 1;

            if ( $values{id} && ( $row = $self->find($values{id}) ) ) {
                $row->attributes->delete;
                $row->update(\%row_values);
            }
            else {
                $row = $self->create(\%row_values);
            }

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

    my $jobs = $self->search(
        {
            status => 'active',
        },
        {
            order_by  => { -desc => 'created_at' },
            rows      => 6,
            columns   => [qw/id title/],
            '+select' => [qw/company.name_in_url company.name job_location.city/],
            '+as'     => [qw/company_url company_name city/],
            join      => [qw/company job_location/],
        }
    );

    for my $j ($jobs->all) {
        push @result, {
            id           => $j->get_column('id'),
            title        => $j->get_column('title'),
            company_url  => $j->get_column('company_url'),
            company_name => $j->get_column('company_name'),
            city         => $j->get_column('city'),
        };
    }

    return \@result;
}

sub get_job_and_company_by_job_id {
    my ( $self, $id ) = @_;

    my $job = $self->find($id);

    return unless $job;

    my $company = $job->company;

    # TODO: get them all, not only first
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

    my $other_jobs = $company->jobs->search({
        'me.id'     => { '!=', $id },
        'me.status' => 'active',
    }, {
        join     => [qw/promoted job_location/],
        order_by => { -desc => [ 'promoted.status', 'created_at' ] }, # promoted first
        rows     => 4,
        select   => [ qw/me.title job_location.city/ ],
        as       => [ qw/title city/ ],
    });

    my $l = $job->job_location;
    if ($l) {
        $l = $l->city;
    }

    return {
        job => {
            id                  => $id,
            title               => $job->title,
            salary              => $job->wages . '/' . _l($job->get_column('wages_for')),
            city                => $l,
            description         => $job->description,
            required_attributes => $job->required_attributes,
            desired_attributes  => $job->desired_attributes,
        },
        company => {
            name_in_url       => $company->name_in_url,
            name              => $company->name,
            description       => $company->description,
            website           => $url,
            email             => $email,
            phone             => $phone,
            formatted_address => $formatted_address,
            other_jobs        => [
                map {
                    +{
                        title => $_->get_column('title'),
                        city  => $_->get_column('city'),
                    }
                } $other_jobs->all
            ],
        },
    };
}

sub get_to_update {
    my ($self, $item_or_id) = @_;
    my ($item, $id);

    if (blessed $item_or_id) {
        $item = $item_or_id;
        $id = $item->id;
    }
    else {
        $id = $item_or_id;
        $item = $self->find($id);
    }

    my %job = (
        id                  => $id,
        status              => $item->get_column('status'),
        company             => $item->get_column('company'),
        title               => $item->get_column('title'),
        description         => $item->get_column('description'),
        vacancies           => $item->get_column('vacancies'),
        phone               => $item->get_column('phone'),
        email               => $item->get_column('email'),
        wages               => $item->get_column('wages'),
        wages_for           => $item->get_column('wages_for'),
        hours               => $item->get_column('hours'),
        hours_by            => $item->get_column('hours_by'),
        is_at_office        => !$item->get_column('is_telecommute'),
        contract_type       => $item->get_column('contract_type'),
        required_attributes => $item->required_attributes,
        desired_attributes  => $item->desired_attributes,
    );

    return {
        map { ( "job.create_or_update.$_" => $job{$_} ) } keys %job
    };
}

sub grid_search {
    my ($self, %data) = @_;

    # TODO: implement sort
    $data{sort} ||= [];

    my $filters = $data{filters} || {};
    my @conditions;

    # TODO: fulltext search
    if (my $t = $filters->{term}) {
        push @conditions, {
           -or => [
                { 'me.title'             => { -ilike => "%$t%" } },
                { 'me.description'       => { -ilike => "%$t%" } },
                { 'attributes.attribute' => { -ilike => "%$t%" } },
           ],
        };
    }

    if ($filters->{companies}) {
        push @conditions, { 'me.company' => { -in => $filters->{companies} } };
    }

    if ($filters->{attributes}) {
        push @conditions, { 'attributes.attribute' => { -in => $filters->{attributes} } };
    }

    # TODO: deal with wages_for, hours and hours_by
    if ($filters->{salary_from}) {
        push @conditions, { 'me.wages' => { '>=' => $filters->{salary_from} } };
    }

    if ($filters->{salary_to}) {
        push @conditions, { 'me.wages' => { '<=' => $filters->{salary_to} } };
    }

    if ($filters->{contract_type}) {
        push @conditions, { 'me.contract_type' => { -in => $filters->{contract_type} } };
    }

    if ($filters->{latlng}) {
        $filters->{radius} ||= '50km';
        # TODO: use postgis to search for radius
    }

    my $search = {
        -and => \@conditions
    };

    my $options = {
        order_by  => $data{sort},
        join      => [ 'job_location', 'attributes', 'company' ],
        '+select' => [ 'job_location.city', 'company.name' ],
        '+as'     => [ 'city', 'company_name' ],
        page      => int($data{page} || 1),
        rows      => int($data{rows} || 10),
    };
    my $rs = $self->search($search, $options);

    my @result;

    for my $row ($rs->all) {
        my $r = {
            id                => $row->get_column('id'),
            created_at        => $row->created_at->strftime('%d/%m/%Y'),
            company           => $row->get_column('company'),
            company_name      => $row->get_column('company_name'),
            title             => $row->get_column('title'),
            description       => $row->get_column('description'),
            salary            => $row->get_column('wages') . '/' . _l($row->get_column('wages_for')),
            phone             => $row->get_column('phone'),
            email             => $row->get_column('email'),
            vacancies         => $row->get_column('vacancies'),
            contract_type     => $row->get_column('contract_type'),
            is_telecommute    => $row->get_column('is_telecommute'),
            city              => $row->get_column('city'),
        };

        # TODO: i18n
        if (my $h = $row->get_column('hours')) {
            my $ch = "$h horas";

            if (my $p = $row->get_column('hours_by')) {
                if ($p eq 'day') {
                    $ch .= " por dia";
                }
                elsif ($p eq 'week') {
                    $ch .= " por semana";
                }
                elsif ($p eq 'month') {
                    $ch .= " por mês";
                }
            }

            $r->{contract_hours} = $ch;
        }

        push @result, $r;
    }

    my $pager = $rs->pager;

    return {
        items => \@result,
        pager => {
            current_page     => $pager->current_page,
            entries_per_page => $pager->entries_per_page,
            total_entries    => $pager->total_entries,
            first_page       => $pager->first_page,
            last_page        => $pager->last_page,
            first_on_page    => $pager->first,
            last_on_page     => $pager->last,
        },
    };
}

sub _l {
    my %l = (
        hour    => 'hora',
        month   => 'mês',
        project => 'projeto',
    );
    return $l{$_[0]};
}

__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;
