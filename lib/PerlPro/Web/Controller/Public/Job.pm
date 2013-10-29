package PerlPro::Web::Controller::Public::Job;
use Moose;
use namespace::autoclean;
use utf8;

BEGIN { extends 'Catalyst::Controller' }

sub base :Chained('/') PathPart('') CaptureArgs(0) {
    my ( $self, $ctx ) = @_;

    $ctx->stash( current_model => 'DB::Job' );
}

sub advanced_search :Chained('base') PathPart('search') Args(0) GET {}

sub list :Chained('base') PathPart('jobs') Args(0) GET {}

sub view :Chained('base') PathPart('job') Args(1) GET {
    my ( $self, $ctx, $job_id ) = @_;

    my $job_company = $ctx->model->get_job_and_company_by_job_id($job_id)
      or $ctx->detach('/not_found');

    $ctx->stash(
        j => $job_company->{job},
        c => $job_company->{company},
    );
}

sub ajax_search :Chained('base') Args(0) GET {
    my ( $self, $ctx ) = @_;

    my $q = $ctx->req->query_params;

    my %params = (
        filters => {},
        page    => 1, # $q->{page},
        rows    => 100, # $q->{rows},
    );

    if (my $ct = $q->{contract_types}) {
        $params{filters}{contract_types} = [ split /,/, $ct ];
    }

    if (my $c = $q->{companies}) {
        $params{filters}{companies} = [ split /,/, $c ];
    }

    if (my $a = $q->{attributes}) {
        $params{filters}{attributes} = [ split /,/, $a ];
    }

    if (my $l = $q->{location}) {
        $params{filters}{location} = $l;
        $params{filters}{is_telecommute} = $q->{is_telecommute};
    }

    if (my $s = $q->{salary_from}) {
        $params{filters}{salary_from} = $s;
    }

    if (my $s = $q->{salary_to}) {
        $params{filters}{salary_to} = $s;
    }

    if (my $s = $q->{terms}) {
        $params{filters}{term} = $s;
    }

    $ctx->stash(
        current_view => 'JSON',
        json_data    => $ctx->model->grid_search(%params),
    );
}

# TODO: move to it's own controller
# This is for the typeahead at the /search page
sub attributes_like :Chained('base') PathPart('attributes') Args(1) GET {
    my ( $self, $ctx, $query ) = @_;

    my $attrs = $ctx->model('DB::Attribute')->get_for_typeahead($query);

    $ctx->stash(
        current_view => 'JSON',
        json_data    => $attrs,
    );
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=encoding utf8

=head1 NAME

PerlPro::Web::Controller::Public::Job - Catalyst Controller

=head1 DESCRIPTION

Controller for viewing, listing and searching open positions for jobs.

=head1 METHODS

=head2 base

Top of the chain for all actions in this controller.

=head2 advanced_search

Page to display "Advanced Search" form. The form will be submitted (via HTTP
method GET) to the L</list> action below, so that the results will be displayed
in the default job listing page.

=head2 list

Lists all the active job open positions (paginated), optionally limited by
search parameters.

=head2 view

View one particular job.

=head1 AUTHOR

André Walker

=head1 LICENSE

This file is part of PerlPro.

PerlPro is free software: you can redistribute it and/or modify it under the
terms of the GNU Affero General Public License as published by the Free
Software Foundation, either version 3 of the License, or (at your option) any
later version.
