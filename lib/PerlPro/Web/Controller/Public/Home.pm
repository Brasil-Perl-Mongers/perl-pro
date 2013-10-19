package PerlPro::Web::Controller::Public::Home;
use Moose;
use namespace::autoclean;
use utf8;

BEGIN { extends 'Catalyst::Controller' }

sub home :Global Args(0) {
    my ( $self, $ctx ) = @_;

    $ctx->stash(
        recent_jobs        => $ctx->model('DB::Job')->get_recent_jobs,
        featured_companies => $ctx->model('DB::Company')->get_featured_companies,
        featured_jobs      => $ctx->model('DB::Job')->get_featured_jobs(5),
        template           => 'public/home.tx',
    );
}

sub about :Global Args(0) {
    my ( $self, $ctx ) = @_;

    $ctx->stash( template => 'public/about.tx' );
}

__PACKAGE__->meta->make_immutable;

1;

=encoding utf-8

=head1 NAME

PerlPro::Web::Controller::Public::Home - Homepage of the application

=head1 DESCRIPTION

Controller to contain the home page.

=head1 METHODS

=head2 home

The home page.

=head2 about

Displays page to explain how the website works.

=head1 AUTHOR

André Walker

=head1 LICENSE

This file is part of PerlPro.

PerlPro is free software: you can redistribute it and/or modify it under the
terms of the GNU Affero General Public License as published by the Free
Software Foundation, either version 3 of the License, or (at your option) any
later version.
