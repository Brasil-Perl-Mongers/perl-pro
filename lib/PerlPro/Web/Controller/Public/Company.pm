package PerlPro::Web::Controller::Public::Company;
use Moose;
use namespace::autoclean;
use utf8;

BEGIN { extends 'Catalyst::Controller' }

sub base :Chained('/') PathPart('company') CaptureArgs(0) {
    my ( $self, $ctx ) = @_;
    $ctx->stash(
        current_model_instance => $ctx->model('DB::Company')
    );
}

sub profile :Chained('base') PathPart('') Args(1) GET {
    my ( $self, $ctx, $company ) = @_;

    $ctx->stash(
        item => $ctx->model->find($company)
    );
}

sub catalog :Chained('base') PathPart('') Args(0) GET {
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

sub register :Chained('base') Does('DisplayExecute') Args(0) {}

sub register_display {
    my ( $self, $ctx ) = @_;
}

sub register_execute {
    my ( $self, $ctx ) = @_;

    # TODO
    # We could deal with DataManager here, if necessary. Although
    # DisplayExecute already does that automatically if we want.
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=encoding utf8

=head1 NAME

PerlPro::Web::Controller::Public::Company - Catalyst Controller

=head1 DESCRIPTION

Controller for browsing companies, and registering a new company.

=head1 METHODS

=head2 base

Top of the chain of all methods in this class.

=head2 profile

Display the profile of a given company.

=head2 catalog

Display a list of all companies registered.

=head2 register

Register a new company.

=head2 register_display

Show the template with the form to register a new company.

=head2 register_execute

Save the form.

=head1 AUTHOR

André Walker

=head1 LICENSE

This file is part of PerlPro.

PerlPro is free software: you can redistribute it and/or modify it under the
terms of the GNU Affero General Public License as published by the Free
Software Foundation, either version 3 of the License, or (at your option) any
later version.
