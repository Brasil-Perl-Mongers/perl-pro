package PerlPro::TestTools::Mech;
use Moose;
use pQuery;
use namespace::autoclean;

extends 'Test::WWW::Mechanize::Catalyst';
with 'WWW::Mechanize::TreeBuilder';

has '+catalyst_app' => ( default => 'PerlPro::Web' );

sub pquery { pQuery( shift->content ) }

__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;
