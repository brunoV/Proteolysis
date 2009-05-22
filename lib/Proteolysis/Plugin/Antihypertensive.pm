package Proteolysis::Plugin::Antihypertensive;
use Moose::Role;
use namespace::clean -except => 'meta';

around pool => sub {
    my ( $orig, $self ) = @_;

    my $pool = $self->$orig;
    $pool->load_plugin('Antihypertensive') if $pool;

    return $pool;
};

1;
