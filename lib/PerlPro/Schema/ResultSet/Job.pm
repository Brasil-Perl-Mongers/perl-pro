package PerlPro::Schema::ResultSet::Job;

use utf8;
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
                phone               => { required => 0, type => Str },
                email               => { required => 0, type => EmailAddress },
                wages               => { required => 1, type => Money },
                wages_for           => { required => 1, type => WagesFor },
                hours               => { required => 1, type => Int },
                hours_by            => { required => 1, type => HoursBy },
                is_at_office        => { required => 0, type => Bool },
                address             => { required => 0, type => Str },
                city                => { required => 0, type => Str },
                state               => { required => 0, type => Str },
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
            for (qw/status company title description phone email wages wages_for hours hours_by contract_type/) {
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

            if ($values{state} && $values{city}) {
                if ($row->job_location) {
                    $row->job_location->update({
                        address => $values{address},
                        city    => $values{city},
                        state   => $values{state},
                    });
                }
                else {
                    $row->create_related('job_location', {
                        address => $values{address},
                        city    => $values{city},
                        state   => $values{state},
                        country => 'Brazil',
                    });
                }
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

sub get_featured_jobs {
    my ($self, $rows) = @_;
    my @result;

    my $jobs = $self->search(
        {
            status => 'active',
        },
        {
            order_by  => \'RANDOM()',
            rows      => ($rows || 5),
            columns   => [qw/id title wages wages_for description created_at/],
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
            description  => $j->get_column('description'),
            city         => $j->get_column('city'),
            created_at   => $j->created_at->set_locale('pt_BR'),
            salary       => $j->wages . ' por ' . _l($j->wages_for),
        };
    }

    return \@result;
}

sub for_company_profile {
    my $self = shift;

    my $search = $self->search({
        'me.status' => 'active',
    }, {
        join      => [qw/promoted job_location/],
        order_by  => { -desc => [ 'promoted.status', 'created_at' ] }, # promoted first
        columns   => [qw/id title created_at description wages wages_for /],
        '+select' => [qw/promoted.status job_location.city/],
        '+as'     => [qw/promotion city/],
    });

    my @jobs = map {
        +{
            id          => $_->get_column('id'),
            title       => $_->get_column('title'),
            description => $_->get_column('description'),
            promotion   => $_->get_column('promotion'),
            city        => $_->get_column('city'),
            created_at  => $_->created_at->set_locale('pt_BR'),
            salary      => $_->wages . ' por ' . _l($_->wages_for),
        }
    } $search->all;

    return \@jobs;
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

    my $job = $self->find($id, {
        join => 'job_location',
        '+select' => ['job_location.address', 'job_location.city', 'job_location.state'],
        '+as' => ['address', 'city', 'state'],
    });

    return unless $job;

    my $company = $job->company;

    my @websites = map {
        $_->url
    } $company->company_websites->search({}, {
        order_by => { -desc => 'is_main_website' }
    })->all;

    my @phones = map {
        $_->phone
    } $company->company_phones->search({ is_public => 1 }, {
        order_by => { -desc => 'is_main_phone' }
    })->all;

    my @emails = map {
        $_->email
    } $company->company_emails->search({ is_public => 1 }, {
        order_by => { -desc => 'is_main_address' }
    })->all;

    my $other_jobs = $company->jobs->search({
        'me.id'     => { '!=', $id },
    })->for_company_profile;

    return {
        job => {
            id                  => $id,
            title               => $job->title,
            phone               => $job->phone,
            email               => $job->email,
            salary              => $job->wages . '/' . _l($job->wages_for),
            hours               => $job->hours . 'h ' . _lh($job->hours_by),
            contract_type       => $job->contract_type,
            address             => $job->get_column('address'),
            city                => $job->get_column('city'),
            state               => uc($job->get_column('state')),
            description         => $job->description,
            required_attributes => $job->required_attributes,
            desired_attributes  => $job->desired_attributes,
        },
        company => {
            name_in_url       => $company->name_in_url,
            name              => $company->name,
            description       => $company->description,
            websites          => \@websites,
            emails            => \@emails,
            phones            => \@phones,
            other_jobs        => $other_jobs,
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

    my $location = $item->job_location;
    my %l;

    %l = (
        address => $location->address,
        city    => $location->city,
        state   => $location->state,
    ) if $location;

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
        address             => $l{address},
        city                => $l{city},
        state               => $l{state},
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

    # TODO: deal with hours and hours_by
    if ($filters->{salary_from}) {
        push @conditions, { 'me.wages' => { '>=' => $filters->{salary_from} } };
    }

    if ($filters->{salary_to}) {
        push @conditions, { 'me.wages' => { '<=' => $filters->{salary_to} } };
    }

    if ($filters->{wages_for}) {
        push @conditions, { 'me.wages_for' => $filters->{wages_for} };
    }

    if ($filters->{contract_types}) {
        push @conditions, { 'me.contract_type' => { -in => $filters->{contract_types} } };
    }

    if (my $l = $filters->{location}) {
        push @conditions, {
           -or => [
                { 'job_location.city' => { -ilike => "%$l%" } },
                { 'job_location.address' => { -ilike => "%$l%" } },
            ],
        };
    }

    if ($filters->{is_telecommute}) {
        push @conditions, { 'me.is_telecommute' => 1 };
    }

    my $search = {
        -and => \@conditions
    };

    my $options = {
        distinct  => 1,
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
            created_at        => $row->created_at->set_locale('pt_BR')->strftime('%d de %B de %Y'),
            company           => $row->get_column('company'),
            company_name      => $row->get_column('company_name'),
            title             => $row->get_column('title'),
            description       => $row->get_column('description'),
            salary            => $row->get_column('wages') . '/' . _l($row->get_column('wages_for')),
            phone             => $row->get_column('phone'),
            email             => $row->get_column('email'),
            contract_type     => $row->get_column('contract_type'),
            is_telecommute    => $row->get_column('is_telecommute'),
            city              => $row->get_column('city'),
        };

        # TODO: i18n
        if (my $h = $row->get_column('hours')) {
            my $ch = "$h horas";

            if (my $p = _lh($row->get_column('hours_by'))) {
                $ch .= ' ' . $p;
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
    return unless $_[0];
    my %l = (
        hour    => 'hora',
        month   => 'mês',
        project => 'projeto',
    );
    return $l{$_[0]};
}

sub _lh {
    return unless $_[0];
    my %l = (
        day     => 'por dia',
        week    => 'semanais',
        month   => 'mensais',
    );
    return $l{$_[0]};
}

__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;
