package Net::Easypost;

use 5.014;

use Moo;
use Hash::Merge::Simple qw(merge);

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

    return Net::Easypost::Address->new(
        $self->send('/address/verify', $address->serialize)->{'address'}
    );
}

sub get_rates {
    my $self = shift;
    my $params = { @_ };

    my $to = Net::Easypost::Address->new( 
        role => 'to', zip => delete $params->{to} 
    );
    
    my $from = Net::Easypost::Address->new( 
        role => 'from', zip => delete $params->{from} 
    );

    my $parcel = Net::Easypost::Parcel->new( $params );

    my $rates = $self->send('/postage/rates', merge(
        $to->serialize,
        $from->serialize,
        $parcel->serialize)
    )->{'rates'};

    my $hr;
    map { $hr->{$_->{carrier}}->{$_->{service}} = $_->{rate} } @{ $rates };

    return $hr;
}





1;
