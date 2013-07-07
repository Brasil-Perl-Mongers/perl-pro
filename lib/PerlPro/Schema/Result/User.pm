use utf8;
package PerlPro::Schema::Result::User;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

PerlPro::Schema::Result::User

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

=head1 TABLE: C<system.user>

=cut

__PACKAGE__->table("system.user");

=head1 ACCESSORS

=head2 login

  data_type: 'text'
  is_nullable: 0

=head2 password

  data_type: 'text'
  is_nullable: 0

=head2 name

  data_type: 'text'
  is_nullable: 0

=head2 created_at

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=head2 modified_at

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=head2 last_login

  data_type: 'timestamp'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "login",
  { data_type => "text", is_nullable => 0 },
  "password",
  { data_type => "text", is_nullable => 0 },
  "name",
  { data_type => "text", is_nullable => 0 },
  "created_at",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
  "modified_at",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
  "last_login",
  { data_type => "timestamp", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</login>

=back

=cut

__PACKAGE__->set_primary_key("login");

=head1 RELATIONS

=head2 user_companies

Type: has_many

Related object: L<PerlPro::Schema::Result::UserCompany>

=cut

__PACKAGE__->has_many(
  "user_companies",
  "PerlPro::Schema::Result::UserCompany",
  { "foreign.user" => "self.login" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 user_emails

Type: has_many

Related object: L<PerlPro::Schema::Result::UserEmail>

=cut

__PACKAGE__->has_many(
  "user_emails",
  "PerlPro::Schema::Result::UserEmail",
  { "foreign.user" => "self.login" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 user_roles

Type: has_many

Related object: L<PerlPro::Schema::Result::UserRole>

=cut

__PACKAGE__->has_many(
  "user_roles",
  "PerlPro::Schema::Result::UserRole",
  { "foreign.user" => "self.login" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 companies

Type: many_to_many

Composing rels: L</user_companies> -> company

=cut

__PACKAGE__->many_to_many("companies", "user_companies", "company");

=head2 roles

Type: many_to_many

Composing rels: L</user_roles> -> role

=cut

__PACKAGE__->many_to_many("roles", "user_roles", "role");


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2013-07-07 00:28:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:tTgPBJWAGNcxKUqe8RINYA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
