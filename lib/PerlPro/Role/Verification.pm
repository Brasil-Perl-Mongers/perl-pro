package PerlPro::Role::Verification;

use Moose::Role;
use PerlPro::Data::Visitor;
use namespace::autoclean;

has verifiers => (
    is         => 'ro',
    isa        => 'HashRef',
    lazy_build => 1,
);

has actions => (
    is         => 'ro',
    isa        => 'HashRef',
    lazy_build => 1,
);

has _visitor => (
    is      => 'ro',
    isa     => 'Data::Visitor',
    lazy    => 1,
    default => sub { PerlPro::Data::Visitor->new },
);

has verifier_scope_name => (
    is         => 'ro',
    isa        => 'Str',
    lazy_build => 1,
);

requires 'verifiers_specs';
requires 'action_specs';
requires '_build_verifier_scope_name';

sub _build_verifiers {
    my $self = shift;
    return $self->_build_map_from_specs( $self->verifiers_specs );
}

sub _build_actions {
    my $self = shift;
    return $self->_build_map_from_specs( $self->action_specs );
}

sub _flatten_specs {
    my ( $self, $specs ) = @_;

    my $v = $self->_visitor;
    $v->visit( { $self->verifier_scope_name => $specs } );

    my $final_specs = $v->final_value;
    $v->_clear_final_value;

    return $final_specs;
}

sub _build_map_from_specs {
    my ( $self, $specs ) = @_;

    my $final_specs = $self->_flatten_specs($specs);

    return +{
        map {
            my $top = $_;
            map { $top . '.' . $_ => $final_specs->{$top}->{$_} }
              keys %{ $final_specs->{$top} }
        } keys %$final_specs
    };
}

no Moose::Role;
1;
