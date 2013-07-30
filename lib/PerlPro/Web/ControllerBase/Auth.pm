package PerlPro::Web::ControllerBase::Auth;
use utf8;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

has first_page => (
    is      => 'ro',
    isa     => 'Str',
    builder => '_build_first_page',
    lazy    => 1,
);

sub requires_login : Chained('base') PathPart('') CaptureArgs(0) {
    my ( $self, $ctx ) = @_;

    if (!$ctx->user) {
        $self->send_to_login($ctx);
    }

    $ctx->stash(
        %{ $ctx->session->{_perlpro_auth_data} }
    );
}

sub send_to_login {
    my ( $self, $ctx ) = @_;

    $ctx->session(
        redirect_after_login_uri => $ctx->req->uri->as_string
    );

    $ctx->res->redirect(
        $ctx->uri_for( $self->action_for('login') )
    );

    $ctx->detach();
}

sub get_auth_data {
    my ( $self, $ctx ) = @_;

    my $obj = $ctx->user->get_object;

    return (
        _perlpro_auth_data => {
            is_logged_in             => 1,
            # company                => ...
            # can_blah_blah          => $ctx->check_user_roles(...)
            # is_blah_blah           => $ctx->check_user_roles(...)
        }
    );
}

sub save_session {
    my ( $self, $ctx ) = @_;
    $ctx->session(
        $self->get_auth_data($ctx)
    );
}

sub login : Chained('base') Does('DisplayExecute') PathPart Args(0) {}

sub login_display {
    my ( $self, $ctx ) = @_;

    if ($ctx->user) {
        $self->save_session($ctx);

        my $session_uri = delete $ctx->session->{redirect_after_login_uri};
        $ctx->res->redirect(
             $session_uri ? $session_uri : $ctx->uri_for($self->first_page)
        );
        $ctx->detach();
    }
}

sub login_execute {
    my ( $self, $ctx ) = @_;

    my $params = $ctx->req->params;

    if (
        $ctx->authenticate({
            login    => $params->{login},
            password => $params->{password},
        })
    ) {
        $ctx->log->info("AUTHENTICATED USER $params->{username}");
    }
    else {
        $ctx->log->info("COULD NOT AUTHENTICATE USER: $params->{username}");
    }
}

sub logout : Chained('base') PathPart Args(0) {
    my ( $self, $ctx ) = @_;

    $ctx->delete_session();
    $ctx->logout;

    $ctx->res->redirect(
        $ctx->uri_for( $self->action_for('login') )
    );
}

__PACKAGE__->meta->make_immutable;

1;
