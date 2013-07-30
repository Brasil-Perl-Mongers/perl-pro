package PerlPro::Data::Manager;

use Moose;
use PerlPro::Data::Visitor;
use namespace::autoclean;

extends 'Data::Manager';

has _input => (
    is       => 'ro',
    isa      => 'HashRef',
    init_arg => 'input'
);

has input => (
    is         => 'ro',
    isa        => 'HashRef',
    init_arg   => undef,
    lazy_build => 1,
);

has actions => (
    is      => 'ro',
    traits  => ['Hash'],
    isa     => 'HashRef',
    default => sub { +{} },
    handles => {
        get_action_for => 'get',
        set_action_for => 'set',
    }
);

has outcomes => (
    is      => 'ro',
    traits  => ['Hash'],
    isa     => 'HashRef',
    lazy    => 1,
    default => sub { +{} },
    handles => {
        get_outcome_for => 'get',
        set_outcome_for => 'set',
    }
);

sub _flatten {
    my ( $self, $href ) = @_;
    my $v = PerlPro::Data::Visitor->new;
    $v->visit($href);
    return $v->final_value;
}

sub _build_input {
    my $self = shift;
    return $self->_flatten( $self->_input );
}

sub apply {
    my ( $self, $input ) = @_;
    $input ||= $self->input;

    foreach my $key ( keys %$input ) {
        $self->apply_one($key, $input->{$key});
    }
}

sub apply_one {
    my ( $self, $key, $input ) = @_;

    return unless $self->verifiers->{$key};

    $input ||= $self->input->{$key};

    my $results = $self->verify( $key, $input );

    my $action  = $self->get_action_for($key);

    if ( $results->success && $action ) {
        $self->set_outcome_for( $key, $action->($results) )
    }
}

around success => sub {
    my $orig = shift;
    my $self = shift;
    return !!( $self->$orig(@_) && scalar keys %{ $self->results } );
};

__PACKAGE__->meta->make_immutable;

1;
