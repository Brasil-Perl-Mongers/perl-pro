use utf8;
package PerlPro::Schema::Result::JobLocation;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

PerlPro::Schema::Result::JobLocation

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::EncodedColumn>

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("EncodedColumn", "InflateColumn::DateTime");

=head1 TABLE: C<job_location>

=cut

__PACKAGE__->table("job_location");

=head1 ACCESSORS

=head2 job

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 latlng

  data_type: 'point'
  is_nullable: 1

=head2 address

  data_type: 'text'
  is_nullable: 1

=head2 city

  data_type: 'text'
  is_nullable: 0

=head2 state

  data_type: 'text'
  is_nullable: 0

=head2 country

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "job",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "latlng",
  { data_type => "point", is_nullable => 1 },
  "address",
  { data_type => "text", is_nullable => 1 },
  "city",
  { data_type => "text", is_nullable => 0 },
  "state",
  { data_type => "text", is_nullable => 0 },
  "country",
  { data_type => "text", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</job>

=back

=cut

__PACKAGE__->set_primary_key("job");

=head1 RELATIONS

=head2 job

Type: belongs_to

Related object: L<PerlPro::Schema::Result::Job>

=cut

__PACKAGE__->belongs_to(
  "job",
  "PerlPro::Schema::Result::Job",
  { id => "job" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07036 @ 2013-10-21 04:15:27
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ShGARABzdCX5A/sKab8Ntg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
