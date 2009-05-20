package Proteolysis::DB;
use Moose;
extends 'KiokuX::Model';
use KiokuDB::TypeMap;
use KiokuDB::TypeMap::Entry::Naive;
use namespace::clean -except => 'meta';

has '+extra_args' => (
    default => sub { {
        create  => 1,
        typemap => KiokuDB::TypeMap->new(
            isa_entries => {
                'Bio::Root::Root' => KiokuDB::TypeMap::Entry::Naive->new,
            }
        ),
    } }
);

__PACKAGE__->meta->make_immutable;
1;
