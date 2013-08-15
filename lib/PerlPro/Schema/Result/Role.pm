use utf8;
package PerlPro::Schema::Result::Role;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

PerlPro::Schema::Result::Role

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

=head1 TABLE: C<role>

=cut

__PACKAGE__->table("role");

=head1 ACCESSORS

=head2 role_name

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns("role_name", { data_type => "text", is_nullable => 0 });

=head1 PRIMARY KEY

=over 4

=item * L</role_name>

=back

=cut

__PACKAGE__->set_primary_key("role_name");

=head1 RELATIONS

=head2 user_roles

Type: has_many

Related object: L<PerlPro::Schema::Result::UserRole>

=cut

__PACKAGE__->has_many(
  "user_roles",
  "PerlPro::Schema::Result::UserRole",
  { "foreign.role" => "self.role_name" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 users

Type: many_to_many

Composing rels: L</user_roles> -> user

=cut

__PACKAGE__->many_to_many("users", "user_roles", "user");


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2013-08-15 14:19:37
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:N6KOb4IYdj0U/zmh60Y2wg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
