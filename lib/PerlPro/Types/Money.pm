package PerlPro::Types::Money;
use Moose::Util::TypeConstraints;
use MooseX::Types::Moose qw/Str/;
use MooseX::Types -declare => [qw/Money/];

# XXX: is this really the best way to validate it? :(

# I tried coercing it into Num (more precisely, using sprintf("%.2f", ...), but
# as PostgreSQL lc_monetary is set to BRL, it doesn't like values like
# "1000000.56". This is the only way I got t/controller_Company-Job.t to pass.

subtype Money, as Str, where {
    return $_ =~ /^(R\$\s*)?(\d{1,3}\.?)(\d{3}\.)*(\,\d{2})?/;
};

no Moose::Util::TypeConstraints;
1;
