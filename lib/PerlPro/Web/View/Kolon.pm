package PerlPro::Web::View::Kolon;
use utf8;
use Moose;
use Text::Xslate qw/html_builder/;
use HTML::FillInForm;
use namespace::autoclean;

extends 'Catalyst::View::Xslate';

has '+expose_methods' => (
    default => sub { {
        l   => 'localize',
        uri => 'view_uri_for',
    } },
);

has '+function' => (
    default => sub { +{
        fif => \&fillinform,
    } }
);

sub ACCEPT_CONTEXT {
    my ($self, $ctx) = @_;
    $ctx->stash->{static_uri} = $ctx->uri_for('/static/');
    return $self;
}

sub view_uri_for {
    my ( $self, $c, $uri ) = @_;
    return $c->uri_for($uri);
}

sub localize {
    my ( $self, $c, $text, @args ) = @_;

    return unless $text;

    # TODO: real localization (if necessary)
    return $text;

    return $c->loc($text, @args) || $text;
}

sub fillinform {
    my ($form_values) = @_;
    return html_builder {
        my ($html) = @_;
        return HTML::FillInForm->fill(\$html, $form_values);
    };
}

__PACKAGE__->meta->make_immutable;

1;
