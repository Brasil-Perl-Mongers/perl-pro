package PerlPro::Web::Controller::Company::Job;
use Moose;
use namespace::autoclean;
use utf8;

BEGIN { extends 'Catalyst::Controller' }

sub index :Path Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched PerlPro::Web::Controller::Company::Job.');
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=encoding utf8

=head1 NAME

PerlPro::Web::Controller::Company::Job - Catalyst Controller

=head1 DESCRIPTION

Controller for a logged in user, from a company, to browse his own jobs and
manage them (CRUD).

=head1 METHODS

=head2 index

=head1 AUTHOR

André Walker

=head1 LICENSE

TODO
