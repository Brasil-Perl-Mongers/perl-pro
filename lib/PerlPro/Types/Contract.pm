package PerlPro::Types::Contract;
use Moose::Util::TypeConstraints;
use MooseX::Types -declare => [qw/ContractType WagesFor HoursBy/];

enum ContractType, [qw/clt pj internship freelance no-contract/];
enum WagesFor, [qw/day month project/];
enum HoursBy, [qw/day week month project/];

no Moose::Util::TypeConstraints;
1;
