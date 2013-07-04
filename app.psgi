use strict;
use warnings;

use PerlPro::Web;

my $app = PerlPro::Web->apply_default_middlewares(PerlPro::Web->psgi_app);
$app;
