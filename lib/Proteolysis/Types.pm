package Proteolysis::Types;
use strict;
use warnings;
use MooseX::Types -declare => [ qw{
    Set Fragment Pool MutablePool Protease Protein Pool DB Percentage
}];
use lib qw(/home/brunov/lib/Proteolysis/lib);
use Class::Autouse qw(Bio::Protease);

role_type  Set,         { role  => 'KiokuDB::Set'               };
class_type Pool,        { class => 'Proteolysis::Pool'          };
class_type MutablePool, { class => 'Proteolysis::Pool::Mutable' };
class_type Protease,    { class => 'Bio::Protease'              };
class_type DB,          { class => 'Proteolysis::DB'            };
subtype Protein, as 'Str';

subtype Percentage,
    as 'Num',
    where { $_[0] >= 0 && $_[0] <= 100 },
    message { "% of hydrolysis should be a number between 0 and 100\n" };

coerce Protease,
    from 'Str',
    via { Bio::Protease->new(specificity => $_) };

__PACKAGE__->meta->make_immutable;
