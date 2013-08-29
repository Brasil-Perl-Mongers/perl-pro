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
        my $escaped = $$html;
        return HTML::FillInForm->fill(\$escaped, $form_values || {});
    };
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=encoding utf-8

=head1 NAME

PerlPro::Web::View::Kolon - Catalyst Xslate View

=head1 SYNOPSIS

See L<PerlPro::Web>

=head1 DESCRIPTION

Catalyst Xslate view, using the Kolon templating language.

=head1 METHODS

=head2 ACCEPT_CONTEXT

=head2 localize

=head2 fillinform

=head2 view_uri_for

=head1 SEE ALSO

L<Catalyst::View::Xslate>, L<Text::Xslate>, L<Text::Xslate::Syntax::Kolon>

=head1 AUTHOR

André Walker

=head1 LICENSE

This file is part of PerlPro.

PerlPro is free software: you can redistribute it and/or modify it under the
terms of the GNU Affero General Public License as published by the Free
Software Foundation, either version 3 of the License, or (at your option) any
later version.
