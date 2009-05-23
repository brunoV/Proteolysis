package Proteolysis::DB;
use Moose;
extends 'KiokuX::Model';
use namespace::autoclean;

has '+extra_args' => (
    default => sub { { create  => 1,} }
);

__PACKAGE__->meta->make_immutable;
