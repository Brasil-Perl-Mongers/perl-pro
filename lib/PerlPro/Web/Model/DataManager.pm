package PerlPro::Web::Model::DataManager;
use Moose;
use namespace::autoclean;
use PerlPro::Data::Manager;

extends 'Catalyst::Model';
with 'Catalyst::Component::InstancePerContext';

sub build_per_context_instance {
    my ( $self, $c ) = @_;

    my @verifiers;
    my @actions;

    foreach my $name ( $c->models ) {
        next if $name !~ /^DB::/;
        my $model = $c->model($name);
        next unless $model->can('meta');

        # This is intentionally naive for the sake of simple examples
        next unless $model->meta->does_role('PerlPro::Role::Verification');

        push @verifiers, %{ $model->verifiers };
        push @actions,   %{ $model->actions };
    }

    my $dm = PerlPro::Data::Manager->new(
        input     => $c->req->params,
        verifiers => { @verifiers },
        actions   => { @actions   },
    );

    return $dm;
}

__PACKAGE__->meta->make_immutable;

1;
