package Proteolysis::Types;
use strict;
use warnings;
use MooseX::Types -declare => [ qw{
    Set Fragment Pool Protease Protein Pool
}];
use Bio::Protease;
use Bio::Seq;


role_type  Set,      { role  => 'KiokuDB::Set'          };
class_type Fragment, { class => 'Proteolysis::Fragment' };
class_type Pool,     { class => 'Proteolysis::Pool'     };
class_type Protease, { class => 'Bio::Protease'         };
subtype Protein, as class_type('Bio::Seq'), where { $_->alphabet eq 'protein' };

coerce Protease,
    from 'Str',
    via {
        Bio::Protease->new(specificity => $_);
    };

coerce Protein,
    from 'Str',
    via {
        Bio::Seq->new(-seq => $_, -alphabet => 'protein')
    };

1;
