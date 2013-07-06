package PerlPro::Web::View::Kolon;
use utf8;
use Moose;
use namespace::autoclean;

extends 'Catalyst::View::Xslate';

has '+expose_methods' => (
    default => sub { {
        l   => 'localize',
        le  => 'localize_error',
        uri => 'view_uri_for',
    } },
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

    return $text;

    return $c->loc($text, @args) || $text;
}

sub localize_error {
    my ( $self, $c, $text, @args ) = @_;

    return unless $text;

    if ($text =~ /^invalid_(.*)/) {
        my $fieldname = $1;
        return 'Este campo está inválido.';
        #return $c->loc("[_1] inválido", $c->loc($fieldname) || $fieldname, @args);
        #return $c->loc("inválido", @args);
    }

    if ($text =~ /^missing_(.*)/) {
        my $fieldname = $1;
        return 'Este campo é obrigatório.';
        #return $c->loc("[_1] é obrigatório", $c->loc($fieldname) || $fieldname, @args);
        #return $c->loc("este campo é obrigatório", @args);
    }

    return shift->localize(@_);
}

__PACKAGE__->meta->make_immutable;

1;
