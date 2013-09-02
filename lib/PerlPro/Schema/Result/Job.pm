use utf8;
package PerlPro::Schema::Result::Job;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

PerlPro::Schema::Result::Job

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

=head1 TABLE: C<job>

=cut

__PACKAGE__->table("job");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'perlpro.job_id_seq'

=head2 created_at

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=head2 last_modified

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=head2 expires_at

  data_type: 'timestamp'
  default_value: (now() + '30 days'::interval)
  is_nullable: 0

=head2 status

  data_type: 'perlpro.job_status'
  default_value: 'active'::perlpro.job_status
  is_nullable: 0
  size: 4

=head2 company

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 0

=head2 title

  data_type: 'text'
  is_nullable: 0

=head2 description

  data_type: 'text'
  is_nullable: 0

=head2 vacancies

  data_type: 'integer'
  default_value: 1
  is_nullable: 0

=head2 phone

  data_type: 'text'
  is_nullable: 1

=head2 email

  data_type: 'text'
  is_nullable: 1

=head2 wages

  data_type: 'money'
  is_nullable: 0

=head2 wages_for

  data_type: 'perlpro.job_wages_for'
  default_value: 'month'::perlpro.job_wages_for
  is_nullable: 0
  size: 4

=head2 hours

  data_type: 'integer'
  default_value: 40
  is_nullable: 0

=head2 hours_by

  data_type: 'perlpro.job_hours_by'
  default_value: 'week'::perlpro.job_hours_by
  is_nullable: 0
  size: 4

=head2 is_telecommute

  data_type: 'boolean'
  default_value: false
  is_nullable: 0

=head2 contract_type

  data_type: 'perlpro.job_contract_type'
  default_value: 'no-contract'::perlpro.job_contract_type
  is_nullable: 0
  size: 4

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "perlpro.job_id_seq",
  },
  "created_at",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
  "last_modified",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
  "expires_at",
  {
    data_type     => "timestamp",
    default_value => \"(now() + '30 days'::interval)",
    is_nullable   => 0,
  },
  "status",
  {
    data_type => "perlpro.job_status",
    default_value => \"'active'::perlpro.job_status",
    is_nullable => 0,
    size => 4,
  },
  "company",
  { data_type => "text", is_foreign_key => 1, is_nullable => 0 },
  "title",
  { data_type => "text", is_nullable => 0 },
  "description",
  { data_type => "text", is_nullable => 0 },
  "vacancies",
  { data_type => "integer", default_value => 1, is_nullable => 0 },
  "phone",
  { data_type => "text", is_nullable => 1 },
  "email",
  { data_type => "text", is_nullable => 1 },
  "wages",
  { data_type => "money", is_nullable => 0 },
  "wages_for",
  {
    data_type => "perlpro.job_wages_for",
    default_value => \"'month'::perlpro.job_wages_for",
    is_nullable => 0,
    size => 4,
  },
  "hours",
  { data_type => "integer", default_value => 40, is_nullable => 0 },
  "hours_by",
  {
    data_type => "perlpro.job_hours_by",
    default_value => \"'week'::perlpro.job_hours_by",
    is_nullable => 0,
    size => 4,
  },
  "is_telecommute",
  { data_type => "boolean", default_value => \"false", is_nullable => 0 },
  "contract_type",
  {
    data_type => "perlpro.job_contract_type",
    default_value => \"'no-contract'::perlpro.job_contract_type",
    is_nullable => 0,
    size => 4,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 attributes

Type: has_many

Related object: L<PerlPro::Schema::Result::Attribute>

=cut

__PACKAGE__->has_many(
  "attributes",
  "PerlPro::Schema::Result::Attribute",
  { "foreign.job" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

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

=head2 job_location

Type: might_have

Related object: L<PerlPro::Schema::Result::JobLocation>

=cut

__PACKAGE__->might_have(
  "job_location",
  "PerlPro::Schema::Result::JobLocation",
  { "foreign.job" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 promotions

Type: has_many

Related object: L<PerlPro::Schema::Result::Promotion>

=cut

__PACKAGE__->has_many(
  "promotions",
  "PerlPro::Schema::Result::Promotion",
  { "foreign.job" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2013-09-02 20:20:32
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:bGavc+dLg7BVHc/xvMZJfg

__PACKAGE__->has_many(
  "promoted",
  "PerlPro::Schema::Result::Promotion",
  sub {
      my $args = shift;

      return {
        "$args->{foreign_alias}.job"    => { -ident => "$args->{self_alias}.id" },
        "$args->{foreign_alias}.status" => 'active',
      };
  },
  { cascade_copy => 0, cascade_delete => 0, join_type => 'LEFT' },
);

sub required_attributes {
    my $self = shift;

    return [
        map { $_->attribute } $self->attributes->search(
            {
                required_or_desired => 'required'
            },
            {
                columns => ['attribute']
            }
        )->all
    ];
}

sub desired_attributes {
    my $self = shift;

    return [
        map { $_->attribute } $self->attributes->search(
            {
                required_or_desired => 'desired'
            },
            {
                columns => ['attribute']
            }
        )->all
    ];
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
