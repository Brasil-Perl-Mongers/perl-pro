package PerlPro::Web::Controller::Root;
use Moose;
use namespace::autoclean;
use utf8;

BEGIN { extends 'Catalyst::Controller' }

__PACKAGE__->config(namespace => '');

sub index :Path Args(0) {
    my ( $self, $ctx ) = @_;

    $ctx->detach('/public/home/home');
}

sub favicon : Path('favicon.ico') Args(0) {
    my ( $self, $ctx ) = @_;
    $ctx->serve_static;
}

sub default :Path {
    my ( $self, $ctx ) = @_;
    $ctx->detach( 'not_found' );
}

sub bad_request :Private {
    my ( $self, $ctx ) = @_;

    $ctx->log->warn("400 on " . $ctx->req->path);

    $ctx->res->status(400);
    $ctx->stash( template => 'error/400.tx' );
}

sub forbidden :Private {
    my ( $self, $ctx ) = @_;

    $ctx->log->warn("403 on " . $ctx->req->path);

    $ctx->res->status(403);
    $ctx->stash( template => 'error/403.tx' );
}

sub not_found :Private {
    my ( $self, $ctx ) = @_;

    $ctx->log->warn("404 on " . $ctx->req->path);

    $ctx->res->status(404);
    $ctx->stash( template => 'error/404.tx' );
}

# This is not :Private because there's no need to detach to it. All that is
# needed to reach this method is to call $ctx->error() anywhere in the app.
sub internal_server_error {
    my ($self, $ctx ) = @_;

    $ctx->log->warn("500 on " . $ctx->req->path);

    $ctx->stash->{errors} = $ctx->error;

    for my $error ( @{ $ctx->error } ) {
        $ctx->log->error($error);
    }

    $ctx->res->status(500);
    $ctx->stash( template => 'error/500.tx' );
    $ctx->clear_errors;
}

sub end : ActionClass('RenderView') {
    my ($self, $ctx) = @_;

    if ( scalar @{ $ctx->error } ) {
        $self->internal_server_error($ctx);
    }
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=encoding utf-8

=head1 NAME

PerlPro::Web::Controller::Root - Root Controller for PerlPro::Web

=head1 DESCRIPTION

Root controller for the PerlPro Web app, with methods used by the entire site.

=head1 METHODS

=head2 index

The root page. Detaches to L<PerlPro::Web::Controller::Public::Home/home>.

=head2 favicon

Delivers the shortcut icon on root/favicon.ico. Browsers request, by default,
the icon from servername/favicon.ico, so we serve statically from there instead
of the default static folder (root/static).

=head2 default

Alias for L</not_found>.

=head2 bad_request

Standard 400 page (Bad Request).

=head2 forbidden

Standard 403 page (Forbidden).

=head2 not_found

Standard 404 page (Not found).

=head2 internal_server_error

Error 500, used whenever C<< $ctx->error >> is called in some action in the
app.

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
