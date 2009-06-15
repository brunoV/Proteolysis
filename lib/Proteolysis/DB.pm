package Proteolysis::DB;
use Moose;
extends 'KiokuX::Model';
use namespace::autoclean;
use KiokuDB::TypeMap;
use KiokuDB::TypeMap::Entry::Naive;
use KiokuDB::TypeMap::Entry::Callback;
use Bio::Protease;

has '+typemap' => (
    default => sub { KiokuDB::TypeMap->new(
            entries => {
                'Bio::Protease' => KiokuDB::TypeMap::Entry::Callback->new(
                    collapse => sub {
                        my $object = shift;

                        my $name = $object->name // 'unknown';

                        return $name;
                    },

                    expand => sub {
                        my ($class, $collapsed) = @_;

                        my $object = $class->new(
                            specificity => $collapsed,
                            name        => $collapsed,
                        );

                        return $object;
                    }
                ),

                'Statistics::Descriptive::Full' => KiokuDB::TypeMap::Entry::Naive->new,
                'Module::Pluggable::Object'     => KiokuDB::TypeMap::Entry::Naive->new,
            }
        ),
    }
);

has '+extra_args' => (
    default => sub { {
        create  => 1,
        log_auto_remove => 1,
    } }
);

__PACKAGE__->meta->make_immutable;
