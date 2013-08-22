package PerlPro::Types::Contract;
use Moose::Util::TypeConstraints;
use MooseX::Types -declare => [qw/ContractHours ContractType/];

enum ContractHours, [qw/fulltime parttime internship freelance/];
enum ContractType, [qw/clt pj internship other/];

no Moose::Util::TypeConstraints;
1;
