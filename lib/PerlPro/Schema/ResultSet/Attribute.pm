package PerlPro::Schema::ResultSet::Attribute;

use Moose;
use namespace::autoclean;

extends 'DBIx::Class::ResultSet';

sub get_for_typeahead {
    my ($self, $query) = @_;

    my $rs = $self->search(
        {
            attribute => { -ilike => "%$query%" }
        },
        {
            columns  => [qw/attribute/],
            distinct => 1,
            rows     => 10,
        }
    );

    return [ map { $_->attribute } $rs->all ];
}

__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;
