package Net::Easypost;

use 5.014;

use Moo;
use Net::Easypost::Address;
use Net::Easypost::Parcel;
use Net::Easypost::Carrier;
use Data::Printer;

# ABSTRACT: Perl client for the Easypost.co service

with('Net::Easypost::Request');

has 'access_code' => (
    is => 'ro',
    required => 1,
);

sub verify_address {
    my $self = shift;

    my $address = Net::Easypost::Address->new( { @_ } );

    p $self->send('/address/verify', $address->serialize);
}







1;
