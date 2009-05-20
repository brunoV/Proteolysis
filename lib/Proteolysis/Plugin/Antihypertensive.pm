package Proteolysis::Plugin::Antihypertensive;
use Moose::Role;
use Modern::Perl;
use namespace::clean -except => 'meta';

around pool => sub {
    my ( $self, $orig ) = @_;

    my $pool = $self->$orig();
    $pool->load_plugin('Antihypertensive') if $pool;

    return $pool;
};

1;
