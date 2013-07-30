package PerlPro::Web::ActionRole::DisplayExecute;
use Moose::Role;

after execute => sub {
    my ( $self, $controller, $ctx, @rest ) = @_;

    my $controller_name = ref $controller;
    $controller_name =~ s/^PerlPro::Web::Controller//;
    $controller_name =~ s/:://g;

    my $name           = $self->{name};
    my $execute_action = "${name}_execute";
    my $display_action = "${name}_display";

    if (my $dm_data = delete $ctx->session->{"_dm_${controller_name}_$name"}) {
        $ctx->stash(%$dm_data);
    }

    if ($ctx->req->method eq 'POST') {
        if ($controller->can($execute_action)) {
            $controller->$execute_action($ctx, @rest);
        }

        my $dm = $ctx->model('DataManager');

        unless ($ctx->stash->{DO_NOT_APPLY_DM}) {
            $dm->apply;
        }

        my @data_for_session = (is_success => $dm->success);

        if (!$dm->success) {
            push @data_for_session, (
                messages   => $dm->messages,
                results    => $dm->results,
            );
        }

        $ctx->session(
            "_dm_${controller_name}_$name" => {
                @data_for_session
            },
        );

        $ctx->session_expire_key("_dm_${controller_name}_$name", 120);

        my $uri_for_args;

        if (my $uri = $ctx->stash->{uri_to_redirect}) {
            $uri_for_args = ref $uri ? $uri : [ $uri ];
        }
        else {
            $uri_for_args = [ $controller->action_for($name), \@rest ];
        }

        $ctx->res->redirect(
            $ctx->uri_for(
                @$uri_for_args
            )
        );

        $ctx->detach;
    }
    elsif ($controller->can($display_action)) {
        $controller->$display_action($ctx, @rest)
    }
};

no Moose::Role;
1;
