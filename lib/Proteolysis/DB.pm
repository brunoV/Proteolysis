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

sub BUILDARGS {
    my ($class, %args) = @_;

    my $columns = [
    # specify extra columns for the 'entries' table
        protease => {
            data_type   => 'varchar',
            is_nullable => 1,
            extract => sub {
                my $obj = shift;
                if (ref $obj eq 'Bio::Protease') {
                    return $obj->name;
                }
            },
        },

        detail_level => {
            data_type   => 'varchar',
            is_nullable => 1,
        },

        dh => {
            data_type   => 'real',
            is_nullable => 1,
        },

        mean_inverse_ace => {
            data_type   => 'real',
            is_nullable => 1,
        },

        mean_length => {
            data_type   => 'real',
            is_nullable => 1,
        },

        substrate_count => {
            data_type   => 'integer',
            is_nullable => 1,
        }

    ];

    $args{extra_args}->{columns} = $columns;

    return $class->SUPER::BUILDARGS(%args);
}

has '+extra_args' => (
    default => sub { {
        create  => 1,
        log_auto_remove => 1,
    } }
);

__PACKAGE__->meta->make_immutable;
