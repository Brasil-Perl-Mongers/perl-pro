package PerlPro::Web::Controller::Public::Home;
use Moose;
use namespace::autoclean;
use utf8;

BEGIN { extends 'Catalyst::Controller' }

sub home :Chained('/') Args(0) {
    my ( $self, $ctx ) = @_;

    $ctx->stash(
        recent_jobs => $ctx->model('DB::Job')->get_recent_jobs,
        template => 'public/home.tx'
    );
}

__PACKAGE__->meta->make_immutable;

1;

=encoding utf-8

=head1 NAME

PerlPro::Web::Controller::Public::Home - Homepage of the application

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=head2 home

The home page.

=head1 AUTHOR

André Walker

=head1 LICENSE

This file is part of PerlPro.

PerlPro is free software: you can redistribute it and/or modify it under the
terms of the GNU Affero General Public License as published by the Free
Software Foundation, either version 3 of the License, or (at your option) any
later version.
