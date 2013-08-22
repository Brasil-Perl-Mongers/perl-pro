package PerlPro::Types::AttributeArray;
use Moose::Util::TypeConstraints;
use MooseX::Types::Moose qw/Str ArrayRef Undef/;
use MooseX::Types -declare => [qw/AttributeArray/];

subtype AttributeArray, as ArrayRef[Str];

coerce AttributeArray, from Undef, via { [] };
coerce AttributeArray, from Str, via { [ split /,/, $_ ] };

no Moose::Util::TypeConstraints;
1;
