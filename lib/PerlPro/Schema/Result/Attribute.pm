use utf8;
package PerlPro::Schema::Result::Attribute;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

PerlPro::Schema::Result::Attribute

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

=head1 TABLE: C<attribute>

=cut

__PACKAGE__->table("attribute");

=head1 ACCESSORS

=head2 job

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 attribute

  data_type: 'text'
  is_nullable: 0

=head2 required_or_desired

  data_type: 'perlpro.attribute_type'
  is_nullable: 0
  size: 4

=cut

__PACKAGE__->add_columns(
  "job",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "attribute",
  { data_type => "text", is_nullable => 0 },
  "required_or_desired",
  { data_type => "perlpro.attribute_type", is_nullable => 0, size => 4 },
);

=head1 PRIMARY KEY

=over 4

=item * L</job>

=item * L</attribute>

=back

=cut

__PACKAGE__->set_primary_key("job", "attribute");

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


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2013-08-15 14:19:37
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:3i84VKV/h0VLVHdqSVtSJw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
