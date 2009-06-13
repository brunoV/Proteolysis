package Proteolysis::Types;
use strict;
use warnings;
use MooseX::Types -declare => [ qw{
    Set Fragment Pool Protease Protein Pool DB
}];
use Bio::Protease;
use Bio::Seq;

role_type  Set,      { role  => 'KiokuDB::Set'          };
class_type Fragment, { class => 'Proteolysis::Fragment' };
class_type Pool,     { class => 'Proteolysis::Pool'     };
class_type Protease, { class => 'Bio::Protease'         };
class_type DB,       { class => 'Proteolysis::DB'       };
subtype Protein, as 'Str';

coerce Protease,
    from 'Str',
    via {
        Bio::Protease->new(specificity => $_);
    };

__PACKAGE__->meta->make_immutable;
