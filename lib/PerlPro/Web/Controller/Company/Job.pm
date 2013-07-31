package PerlPro::Web::Controller::Company::Job;
use Moose;
use namespace::autoclean;
use utf8;

BEGIN { extends 'Catalyst::Controller' }

sub base :Chained('/company/auth/requires_login') PathPart('') CaptureArgs(0) {}

sub index :Chained('base') PathPart('my_jobs') Args(0) GET {
    my ( $self, $ctx ) = @_;

    # display listing with all jobs of this company
    # load data from DB

    $ctx->stash(
        template => 'company/my_jobs.tx',
        current_page => 'my_jobs',
    );
}

sub remove :Chained('base') PathPart('job') Args(1) DELETE {
    my ( $self, $ctx ) = @_;

    # remove job, return HTTP code for success, and some data like "OK"
}

sub add_job :Chained('base') Does('DisplayExecute') Args(0) {
    my ( $self, $ctx ) = @_;

    $ctx->stash(
        template => 'company/add_job.tx',
        current_page => 'add_job',
    );
}

sub update_job :Chained('base') Does('DisplayExecute') Args(0) {
    my ( $self, $ctx ) = @_;

    $ctx->stash(
        template => 'company/update_job.tx',
        current_page => 'my_jobs', # just to color something in the menu
    );
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=encoding utf8

=head1 NAME

PerlPro::Web::Controller::Company::Job - Catalyst Controller

=head1 DESCRIPTION

Controller for a logged in user, from a company, to browse his own jobs and
manage them (CRUD).

=head1 METHODS

=head2 base

=head2 index

=head2 remove

=head2 add_job

=head2 update_job

=head1 AUTHOR

André Walker

=head1 LICENSE

This file is part of PerlPro.

PerlPro is free software: you can redistribute it and/or modify it under the
terms of the GNU Affero General Public License as published by the Free
Software Foundation, either version 3 of the License, or (at your option) any
later version.
