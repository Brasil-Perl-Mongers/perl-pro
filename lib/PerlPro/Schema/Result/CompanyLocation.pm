use utf8;
package PerlPro::Schema::Result::CompanyLocation;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

PerlPro::Schema::Result::CompanyLocation

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

=head1 TABLE: C<company.company_location>

=cut

__PACKAGE__->table("company.company_location");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'company.company_location_id_seq'

=head2 company

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 0

=head2 address

  data_type: 'text'
  is_nullable: 0

=head2 city

  data_type: 'text'
  is_nullable: 0

=head2 state

  data_type: 'text'
  is_nullable: 0

=head2 country

  data_type: 'text'
  is_nullable: 0

=head2 is_main_address

  data_type: 'boolean'
  default_value: false
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "company.company_location_id_seq",
  },
  "company",
  { data_type => "text", is_foreign_key => 1, is_nullable => 0 },
  "address",
  { data_type => "text", is_nullable => 0 },
  "city",
  { data_type => "text", is_nullable => 0 },
  "state",
  { data_type => "text", is_nullable => 0 },
  "country",
  { data_type => "text", is_nullable => 0 },
  "is_main_address",
  { data_type => "boolean", default_value => \"false", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 company

Type: belongs_to

Related object: L<PerlPro::Schema::Result::Company>

=cut

__PACKAGE__->belongs_to(
  "company",
  "PerlPro::Schema::Result::Company",
  { name_in_url => "company" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2013-07-30 11:17:17
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:9O8wue36qamNJDTSfvOSfA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
