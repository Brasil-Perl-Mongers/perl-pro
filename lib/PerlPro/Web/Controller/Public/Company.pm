package PerlPro::Web::Controller::Public::Company;
use Moose;
use namespace::autoclean;
use utf8;

BEGIN { extends 'Catalyst::Controller' }

sub base :Chained('/') PathPart('') CaptureArgs(0) {
    my ( $self, $ctx ) = @_;
    $ctx->stash(
        current_model_instance => $ctx->model('DB::Company')
    );
}

sub profile :Chained('base') PathPart('company') Args(1) GET {
    my ( $self, $ctx, $company ) = @_;

    $ctx->stash(
        item => $ctx->model->find($company)
    );
}

sub catalog :Chained('base') PathPart('companies') Args(0) GET {
    my ( $self, $ctx ) = @_;

    # TODO: paging
    # This is obviously dangerous as it could potentially lock the database and
    # completely fill memory, but it's good enough for a MVP, as we don't
    # expect millions of companies too soon.
    # But it should be fixed soon.
    $ctx->stash(
        companies => [ $ctx->model->search->all ]
    );
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=encoding utf8

=head1 NAME

PerlPro::Web::Controller::Public::Company - Catalyst Controller

=head1 DESCRIPTION

Controller for browsing companies.

=head1 METHODS

=head2 base

Top of the chain of all methods in this class.

=head2 profile

Display the profile of a given company.

=head2 catalog

Display a list of all companies registered.

=head1 AUTHOR

André Walker

=head1 LICENSE

This file is part of PerlPro.

PerlPro is free software: you can redistribute it and/or modify it under the
terms of the GNU Affero General Public License as published by the Free
Software Foundation, either version 3 of the License, or (at your option) any
later version.
