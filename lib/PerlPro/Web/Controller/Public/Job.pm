package PerlPro::Web::Controller::Public::Job;
use Moose;
use namespace::autoclean;
use utf8;

BEGIN { extends 'Catalyst::Controller' }

sub index :Path Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched PerlPro::Web::Controller::Public::Job in Public::Job.');
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

=head2 index

=head1 AUTHOR

André Walker

=head1 LICENSE

This file is part of PerlPro.

PerlPro is free software: you can redistribute it and/or modify it under the
terms of the GNU Affero General Public License as published by the Free
Software Foundation, either version 3 of the License, or (at your option) any
later version.
