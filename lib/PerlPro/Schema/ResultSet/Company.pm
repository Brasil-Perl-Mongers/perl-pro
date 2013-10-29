package PerlPro::Schema::ResultSet::Company;

use Moose;
use namespace::autoclean;

extends 'DBIx::Class::ResultSet';
with 'PerlPro::Role::Verification';

use MooseX::Types::Email qw/EmailAddress/;
use MooseX::Types::Moose qw/Str Bool/;
use MooseX::Types::URI qw/Uri/;
use HTML::Entities ();
use Text::Unaccent::PurePerl ();

use Data::Verifier;

sub _build_verifier_scope_name { 'company' }

sub verifiers_specs {
    my $self = shift;

    return {
        register => Data::Verifier->new(
            profile => {
                name    => { required => 1, type => Str },
                email   => { required => 1, type => EmailAddress },
                phone   => { required => 0, type => Str },
                address => { required => 0, type => Str },
                city    => { required => 0, type => Str },
                state   => { required => 0, type => Str },
            },
            filters => [
                sub { HTML::Entities::encode_entities( $_[0], qr{<>&"'} ) }
            ],
        ),
        account => Data::Verifier->new(
            profile => {
                name_in_url => { required => 1, type => Str },
                login       => { required => 1, type => Str },
                email       => { required => 1, type => EmailAddress },
                phone       => { required => 0, type => Str },
                address     => { required => 0, type => Str },
                city        => { required => 0, type => Str },
                state       => { required => 0, type => Str },
            },
        ),
        public_profile => Data::Verifier->new(
            profile => {
                name_in_url => { required => 1, type => Str },
                name        => { required => 1, type => Str },
                description => { required => 0, type => Str },
                website     => { required => 0, type => Uri, coerce => 1 },
                email       => { required => 0, type => EmailAddress },
                phone       => { required => 0, type => Str },
                address     => { required => 0, type => Str },
                city        => { required => 0, type => Str },
                state       => { required => 0, type => Str },
            },
        ),
        add_email => Data::Verifier->new(
            profile => {
                company => { required => 1, type => Str          },
                email   => { required => 1, type => EmailAddress },
                is_main => { required => 0, type => Bool         },
            },
        ),
        add_phone => Data::Verifier->new(
            profile => {
                company => { required => 1, type => Str  },
                phone   => { required => 1, type => Str  },
                is_main => { required => 0, type => Bool },
            },
        ),
        add_website => Data::Verifier->new(
            profile => {
                company => { required => 1, type => Str  },
                url     => { required => 1, type => Uri  },
                is_main => { required => 0, type => Bool },
            },
        ),
        add_location => Data::Verifier->new(
            profile => {
                company  => { required => 1, type => Str  },
                location => { required => 1, type => Str  }, # FIXME
                is_main  => { required => 0, type => Bool },
            },
        ),
    };
}

sub action_specs {
    my $self = shift;
    return {
        register => sub {
            my %values = shift->valid_values;

            my $name_in_url = lc Text::Unaccent::PurePerl::unac_string($values{name});
            $name_in_url =~ s/\s+/_/g;
            $name_in_url =~ s/[^a-z0-9_]//g;

            my $row = $self->create({
                name_in_url => $name_in_url,
                name        => $values{name},
                description => $values{description},
            });

            $row->add_to_company_emails({
                email           => $values{email},
                is_main_address => 1,
                is_public       => 0
            });
            if ($values{phone}) {
                $row->add_to_company_phones({
                    phone         => $values{phone},
                    is_main_phone => 1,
                    is_public     => 0,
                });
            }

            if ($values{city} && $values{state}) {
                $row->add_to_company_locations({
                    address         => $values{address},
                    city            => $values{city},
                    state           => $values{state},
                    country         => 'Brazil', # later on, it won't be hardcoded
                    is_main_address => 1,
                    is_public       => 0,
                });
            }

            return $row;
        },
        account => sub {
            my %values = shift->valid_values;

            my $row = $self->find($values{name_in_url});

            $row->company_emails->search({ is_public => 0 })->delete;
            $row->company_phones->search({ is_public => 0 })->delete;
            $row->company_locations->search({ is_public => 0 })->delete;

            $row->add_to_company_emails({ is_public => 0, email => $values{email} });
            if ($values{phone}) {
                $row->add_to_company_phones({ is_public => 0, phone => $values{phone} });
            }
            if ($values{city} && $values{state}) {
                $row->add_to_company_locations({
                    is_public => 0,
                    address   => $values{address},
                    city      => $values{city},
                    state     => $values{state},
                    country   => 'Brazil',
                });
            }

            my $user = $row->users->first;
            $user->update({ login => $values{login} });
            $user->user_emails->search({ is_main_address => 1 })->first->update({
                email => $values{email}
            });

            return $row;
        },
        public_profile => sub {
            my %values = shift->valid_values;

            my $row = $self->find($values{name_in_url});
            $row->update({
                name        => $values{name},
                description => $values{description},
            });

            $row->company_websites->delete;
            $row->company_emails->search({ is_public => 1 })->delete;
            $row->company_phones->search({ is_public => 1 })->delete;
            $row->company_locations->search({ is_public => 1 })->delete;

            if ($values{website}) {
                $row->add_to_company_websites({ url => $values{website} });
            }

            if ($values{email}) {
                $row->add_to_company_emails({ is_public => 1, email => $values{email} });
            }

            if ($values{phone}) {
                $row->add_to_company_phones({ is_public => 1, phone => $values{phone} });
            }

            if ($values{city} && $values{state}) {
                $row->add_to_company_locations({
                    is_public => 1,
                    address   => $values{address},
                    city      => $values{city},
                    state     => $values{state},
                    country   => 'Brazil',
                });
            }

            return $row;
        },
        add_email => sub {
            my %values = shift->valid_values;
            my $row = $self->find($values{company});
            $row->add_to_emails({
                email => $values{email},
                is_main_address => $values{is_main},
            });
            return $row;
        },
        add_phone => sub {
            my %values = shift->valid_values;
            my $row = $self->find($values{company});
            $row->add_to_phones({
                phone => $values{phone},
                is_main_phone => $values{is_main},
            });
            return $row;
        },
        add_website => sub {
            my %values = shift->valid_values;
            my $row = $self->find($values{company});
            $row->add_to_websites({
                url => $values{url},
                is_main_website => $values{is_main},
            });
            return $row;
        },
        add_location => sub {
            my %values = shift->valid_values;
            my $row = $self->find($values{company});
            $row->add_to_locations({
                location => $values{location},          # FIXME
                is_main_address => $values{is_main},
            });
            return $row;
        },
    };
}

sub get_for_profile {
    my ($self, $id) = @_;

    my $company = $self->find($id);

    return unless $company;

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

    my @locations = map {
        $_->address . ", " . $_->city  . " - " . uc($_->state)
    } $company->company_locations->search({ is_public => 1 }, {
        order_by => { -desc => 'is_main_address' }
    })->all;

    return {
        name_in_url => $company->name_in_url,
        name        => $company->name,
        description => $company->description,
        websites    => \@websites,
        emails      => \@emails,
        phones      => \@phones,
        addresses   => \@locations,
        jobs        => $company->jobs->for_company_profile,
    }
}

sub get_to_update_account {
    my ($self, $login, $id) = @_;

    my $company = $self->find($id);

    return unless $company;

    my @phones = $company->company_phones->search(
        { is_public => 0 },
        { rows => 1 }
    )->all;
    my @emails = $company->users->find($login)->user_emails->search(
        {},
        {
            order_by => { -desc => 'is_main_address' },
            rows     => 1,
        }
    )->all;
    my @locations = $company->company_locations->search(
        { is_public => 0 },
        { rows => 1 }
    )->all;

    my ($phone) = map { $_->phone } @phones;
    my ($email) = map { $_->email } @emails;
    my ($address, $city, $state) = map { ($_->address, $_->city, $_->state) } @locations;

    my %account = (
        email          => $email,
        phone          => $phone,
        address        => $address,
        city           => $city,
        state          => $state,
        login          => $login,
        open_positions => $company->jobs->search({ status => 'active' })->count,
    );

    return {
        map { ( "company.account.$_" => $account{$_} ) } keys %account
    };
}

sub get_to_update_public_profile {
    my ($self, $id) = @_;

    my $company = $self->find($id);

    return unless $company;

    my @websites = $company->company_websites->search({}, {
        order_by => { -desc => 'is_main_website' },
        rows => 1,
    })->all;
    my @phones   = $company->company_phones->search({ is_public => 1 }, {
        order_by => { -desc => 'is_main_phone' },
        rows => 1,
    })->all;
    my @emails   = $company->company_emails->search({ is_public => 1 }, {
        order_by => { -desc => 'is_main_address' },
        rows => 1,
    })->all;
    my @locations = $company->company_locations->search({ is_public => 1 }, {
        order_by => { -desc => 'is_main_address' },
        rows => 1,
    })->all;

    my ($website) = map { $_->url } @websites;
    my ($phone) = map { $_->phone } @phones;
    my ($email) = map { $_->email } @emails;
    my ($address, $city, $state) = map { ($_->address, $_->city, $_->state) } @locations;

    my %profile = (
        name_in_url    => $id,
        name           => $company->name,
        description    => $company->description,
        website        => $website,
        email          => $email,
        phone          => $phone,
        address        => $address,
        city           => $city,
        state          => $state,
    );

    return {
        map { ( "company.public_profile.$_" => $profile{$_} ) } keys %profile
    };
}

sub get_featured_companies {
    my $self = shift;
    my @result;

    my $rs = $self->search( {}, {
        distinct  => 1,
        rows      => 3,
        order_by  => { -desc => [ 'active_jobs', 'me.mtime' ] },
        '+select' => [
            {
                count => 'jobs.id',
                -as   => 'active_jobs'
            }
        ],
        '+as'    => ['open_positions'],
        '+where' => { 'jobs.status' => 'active' },
        columns  => [qw/name_in_url name/],
        join     => 'jobs',
    } );

    for ( $rs->all ) {
        push @result, {
            name_in_url    => $_->name_in_url,
            name           => $_->name,
            open_positions => $_->get_column('open_positions'),
        };
    }

    return \@result;
}

sub get_for_catalog {
    my ($self, $page) = @_;

    # TODO: real paging
    my $search = $self->search({}, { rows => 50, page => $page });
    my @result;

    for my $c ($search->all) {
        my $website_obj = $c->company_websites->search({}, {
            order_by => { -desc => 'is_main_website' }
        })->first;
        my $location_obj = $c->company_locations->search({}, {
            order_by => { -desc => 'is_main_address' }
        })->first;

        push @result, {
            name           => $c->name,
            name_in_url    => $c->name_in_url,
            open_positions => $c->jobs->search({ status => 'active' })->count,
            website        => $website_obj  ? $website_obj->url   : '',
            city           => $location_obj ? $location_obj->city : '',
        };
    }

    return {
        companies => \@result,
        pager => $search->pager,
    };
}

sub get_for_typeahead {
    my ($self, $query) = @_;
    my @result;

    my $rs = $self->search(
        {
            name => { -ilike => "%$query%" }
        },
        {
            columns => [ qw/name_in_url name/ ],
            rows => 10,
        }
    );

    for ($rs->all) {
        push @result, { name_in_url => $_->name_in_url, name => $_->name };
    }

    return \@result;
}

__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;
