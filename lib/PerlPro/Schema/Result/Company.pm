use utf8;
package PerlPro::Schema::Result::Company;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

PerlPro::Schema::Result::Company

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

=head1 TABLE: C<company.company>

=cut

__PACKAGE__->table("company.company");

=head1 ACCESSORS

=head2 name_in_url

  data_type: 'text'
  is_nullable: 0

=head2 name

  data_type: 'text'
  is_nullable: 0

=head2 description

  data_type: 'text'
  is_nullable: 1

=head2 ctime

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=head2 mtime

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=head2 balance

  data_type: 'money'
  default_value: 'R$ 0,00'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "name_in_url",
  { data_type => "text", is_nullable => 0 },
  "name",
  { data_type => "text", is_nullable => 0 },
  "description",
  { data_type => "text", is_nullable => 1 },
  "ctime",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
  "mtime",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
  "balance",
  { data_type => "money", default_value => "R\$ 0,00", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</name_in_url>

=back

=cut

__PACKAGE__->set_primary_key("name_in_url");

=head1 UNIQUE CONSTRAINTS

=head2 C<company_name_key>

=over 4

=item * L</name>

=back

=cut

__PACKAGE__->add_unique_constraint("company_name_key", ["name"]);

=head1 RELATIONS

=head2 jobs

Type: has_many

Related object: L<PerlPro::Schema::Result::Job>

=cut

__PACKAGE__->has_many(
  "jobs",
  "PerlPro::Schema::Result::Job",
  { "foreign.company" => "self.name_in_url" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 user_companies

Type: has_many

Related object: L<PerlPro::Schema::Result::UserCompany>

=cut

__PACKAGE__->has_many(
  "user_companies",
  "PerlPro::Schema::Result::UserCompany",
  { "foreign.company" => "self.name_in_url" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 users

Type: many_to_many

Composing rels: L</user_companies> -> user

=cut

__PACKAGE__->many_to_many("users", "user_companies", "user");


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2013-07-07 00:28:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:nbZopZOpopsnOi8vhxyCyw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
