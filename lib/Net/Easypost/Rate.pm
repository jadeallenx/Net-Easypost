package Net::Easypost::Rate;

use 5.014;
use Moo;

has 'carrier' => (
    is => 'ro',
    lazy => 1,
    default => sub { 'USPS' }
);

has 'service' => (
    is => 'ro',
);

has 'rate' => (
    is => 'ro',
);

sub serialize {
    my $self = shift;

    my %h = map { $_ => $self->$_ } 
        grep { defined $self->$_ } qw(carrier service rate);

    return \%h;
}


1;

