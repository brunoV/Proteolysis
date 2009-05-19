use MooseX::Declare;
use Modern::Perl;

role Proteolysis::Plugin::Antihypertensive {
    around pool {
        my $pool = $self->$orig();
        $pool->load_plugin('Antihypertensive') if $pool;

        return $pool;
    }
}
