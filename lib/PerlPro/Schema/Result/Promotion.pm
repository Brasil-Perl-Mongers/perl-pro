use utf8;
package PerlPro::Schema::Result::Promotion;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

PerlPro::Schema::Result::Promotion

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

=head1 TABLE: C<job.promotion>

=cut

__PACKAGE__->table("job.promotion");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'job.promotion_id_seq'

=head2 job

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 status

  data_type: 'job.promotion_status'
  default_value: 'pending-payment'::job.promotion_status
  is_nullable: 0
  size: 4

=head2 begins_at

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=head2 ends_at

  data_type: 'timestamp'
  default_value: (now() + '30 days'::interval)
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "job.promotion_id_seq",
  },
  "job",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "status",
  {
    data_type => "job.promotion_status",
    default_value => \"'pending-payment'::job.promotion_status",
    is_nullable => 0,
    size => 4,
  },
  "begins_at",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
  "ends_at",
  {
    data_type     => "timestamp",
    default_value => \"(now() + '30 days'::interval)",
    is_nullable   => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

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


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2013-07-07 00:28:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:jNT6LxoHJbXUv1gabcn5mQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
