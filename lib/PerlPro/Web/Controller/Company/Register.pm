package PerlPro::Web::Controller::Company::Register;
use Moose;
use namespace::autoclean;
use utf8;

BEGIN { extends 'Catalyst::Controller' }

sub base :Chained('/') PathPart('account') CaptureArgs(0) {
    my ( $self, $ctx ) = @_;
    $ctx->stash(
        current_model_instance => $ctx->model('DB::Company')
    );
}

sub register :Chained('base') PathPart('new') Does('DisplayExecute') Args(0) {}

sub register_display {
    my ( $self, $ctx ) = @_;

    $ctx->stash( template => 'company/register.tx' );
}

sub register_execute {
    my ( $self, $ctx ) = @_;

    $ctx->stash->{DO_NOT_APPLY_DM} = 1;

    my $dm = $ctx->model('DataManager');
    my $params = $ctx->req->params;
    my $user = $params->{user}{register};
    my $company = $params->{company}{register};

    $dm->apply_one('company.register', $company);

    my $company_obj = $dm->get_outcome_for('company.register');

    if ($company_obj) {
        $user->{company} = $company_obj->name_in_url;
    }

    $dm->apply_one('user.register', $user);

    if (!$dm->success) {
        $ctx->log->warn('registration form invalid');
        $company_obj->delete if $company_obj;
    }

    $ctx->stash(
        fields => {}, # TODO: deal with $dm->results
    );
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=encoding utf8

=head1 NAME

PerlPro::Web::Controller::Company::Register - Catalyst Controller

=head1 DESCRIPTION

Controller for users who want to register in the website.

=head1 METHODS

=head2 register

Register a new company.

=head2 register_display

Display the form.

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
