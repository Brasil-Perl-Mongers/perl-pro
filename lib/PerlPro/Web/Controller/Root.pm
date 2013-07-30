package PerlPro::Web::Controller::Root;
use Moose;
use namespace::autoclean;
use utf8;

BEGIN { extends 'Catalyst::Controller' }

__PACKAGE__->config(namespace => '');

sub index :Path :Args(0) {}

sub default :Path {
    my ( $self, $c ) = @_;
    $c->response->body( 'Page not found' );
    $c->response->status(404);
}

sub end : ActionClass('RenderView') {}

__PACKAGE__->meta->make_immutable;

1;

=encoding utf-8

=head1 NAME

PerlPro::Web::Controller::Root - Root Controller for PerlPro::Web

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=head2 index

The root page (/)

=head2 default

Standard 404 error page

=head2 end

Attempt to render a view, if needed.

=head1 AUTHOR

André Walker

=head1 LICENSE

This file is part of PerlPro.

PerlPro is free software: you can redistribute it and/or modify it under the
terms of the GNU Affero General Public License as published by the Free
Software Foundation, either version 3 of the License, or (at your option) any
later version.
