package Proteolysis::DB;
use Moose;
extends 'KiokuX::Model';
use namespace::autoclean;
use KiokuDB::TypeMap;
use KiokuDB::TypeMap::Entry::Callback;
use Bio::Protease;

has '+extra_args' => (
    default => sub { {
        create  => 1,
        log_auto_remove => 1,
        typemap => KiokuDB::TypeMap->new(
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
            }
        ),
    } }
);

__PACKAGE__->meta->make_immutable;
