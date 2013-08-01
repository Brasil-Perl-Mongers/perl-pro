package PerlPro::Web::Controller::Company::Auth;
use Moose;
use namespace::autoclean;
use utf8;

BEGIN { extends 'PerlPro::Web::ControllerBase::Auth' }

sub base : Chained('/') PathPart('company') CaptureArgs(0) {}

sub _build_first_page { '/company/home' }

after login_display => sub {
    my ( $self, $ctx ) = @_;
    $ctx->stash(
        template => 'company/login.tx'
    );
};

around get_auth_data => sub {
    my $orig = shift;
    my $self = shift;
    my $ctx  = shift;

    my %result = $self->$orig($ctx, @_);

    my $obj = $ctx->user->get_object;

    $result{_perlpro_auth_data}{is_admin} = 0;
    $result{_perlpro_auth_data}{user}     = $obj;
    $result{_perlpro_auth_data}{company}  = $obj->user_companies->first->company;

    return %result;
};

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=encoding utf8

=head1 NAME

PerlPro::Web::Controller::Company::Auth - Catalyst Controller

=head1 DESCRIPTION

Login, logout, and session management.

=head1 SEE ALSO

L<PerlPro::Web::ControllerBase::Auth>

=head1 AUTHOR

André Walker

=head1 LICENSE

This file is part of PerlPro.

PerlPro is free software: you can redistribute it and/or modify it under the
terms of the GNU Affero General Public License as published by the Free
Software Foundation, either version 3 of the License, or (at your option) any
later version.
