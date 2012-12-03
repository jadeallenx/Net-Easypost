package Net::Easypost::Rate;

use 5.014;
use Moo;

# ABSTRACT: An object to represent an Easypost shipping rate

=attr carrier

The shipping carrier. At the current time, the United States Postal Service (USPS) is the only
supported carrier.

=cut

has 'carrier' => (
    is => 'ro',
    lazy => 1,
    default => sub { 'USPS' }
);

=attr service

The shipping service name. For example, for the USPS, these include 'Priority', 'Express',
'Media Mail' and others.

=cut

has 'service' => (
    is => 'ro',
);

=attr rate

The price in US dollars to ship using the associated carrier and service.

=cut

has 'rate' => (
    is => 'ro',
);

=method serialize

Format this object into a form suitable to use with Easypost.

=cut

sub serialize {
    my $self = shift;

    my %h = map { $_ => $self->$_ } 
        grep { defined $self->$_ } qw(carrier service rate);

    return \%h;
}


1;

