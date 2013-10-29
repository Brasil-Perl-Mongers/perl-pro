package PerlPro::Web::Controller::Company::Data;
use Moose;
use namespace::autoclean;
use Imager;
use utf8;

BEGIN { extends 'Catalyst::Controller' }

sub base :Chained('/company/auth/requires_login') PathPart('') CaptureArgs(0) {
    my ( $self, $ctx ) = @_;

    $ctx->stash(current_model => 'DB::Company');
}

sub home :Chained('base') Does('DisplayExecute') Args(0) {
    my ( $self, $ctx ) = @_;

    $ctx->stash(
        template     => 'company/home.tx',
        current_page => 'home',
        fields       => $ctx->model->get_to_update_account(
            $ctx->user->get_object->login,
            $ctx->stash->{company}
        ),
    );
}

sub home_execute {
    my ( $self, $ctx ) = @_;

    $ctx->stash->{DO_NOT_APPLY_DM} = 1;

    my $dm      = $ctx->model('DataManager');
    my $params  = $ctx->req->params;
    my $company = $params->{company}{account};
    $company->{name_in_url} = $ctx->stash->{company};

    $dm->apply_one( 'company.account', $company );

    if (my $obj = $dm->get_outcome_for('company.account')) {
        $ctx->set_authenticated($ctx->find_user({ login => $obj->users->first->login }));
    }
}


sub profile :Chained('base') Does('DisplayExecute') Args(0) {
    my ( $self, $ctx ) = @_;

    $ctx->stash(
        template     => 'company/profile.tx',
        current_page => 'profile',
        fields       => $ctx->model->get_to_update_public_profile(
            $ctx->stash->{company}
        ),
    );
}

sub profile_execute {
    my ( $self, $ctx ) = @_;

    $ctx->stash->{DO_NOT_APPLY_DM} = 1;

    my $dm      = $ctx->model('DataManager');
    my $params  = $ctx->req->params;
    my $company = $params->{company}{public_profile};
    $company->{name_in_url} = $ctx->stash->{company};

    $dm->apply_one( 'company.public_profile', $company );

    for ($ctx->req->upload) {
        my $file = $ctx->req->upload($_);

        my $img = Imager->new(file => $file->tempname);

        my $prefix = $ctx->config->{root} . '/static/data/uploads/' . $ctx->stash->{company};

        my %sizes = (
            update_profile => [ 180, 160 ],
            public_profile => [ 130,  80 ],
            catalog        => [ 200, 170 ],
            home           => [ 800, 300 ],
        );

        for (keys %sizes) {
            my $t = $img->scale( xpixels => $sizes{$_}[0], ypixels => $sizes{$_}[1] )
                        ->crop( width => $sizes{$_}[0], height => $sizes{$_}[1]);

            $t->write(file => $prefix . "-$_.png");

            if ($t->errstr) {
                die $t->errstr;
            }
        }
    }
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=encoding utf8

=head1 NAME

PerlPro::Web::Controller::Company::Job - Catalyst Controller

=head1 DESCRIPTION

Controller for a logged in user, from a company, update company data.

=head1 METHODS

=head2 base

=head2 display

=head2 update

=head2 add_data

=head2 remove_data

=head1 AUTHOR

André Walker

=head1 LICENSE

This file is part of PerlPro.

PerlPro is free software: you can redistribute it and/or modify it under the
terms of the GNU Affero General Public License as published by the Free
Software Foundation, either version 3 of the License, or (at your option) any
later version.
