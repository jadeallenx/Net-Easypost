package Net::Easypost;

use 5.014;

use Moo;
use Hash::Merge::Simple qw(merge);

use Net::Easypost::Address;
use Net::Easypost::Parcel;
use Net::Easypost::Rate;
use Net::Easypost::Label;
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
        $self->post('/address/verify', $address->serialize)->{'address'}
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

    my $rates = $self->post('/postage/rates', merge(
        $to->serialize,
        $from->serialize,
        $parcel->serialize)
    )->{'rates'};

    return map { 
        Net::Easypost::Rate->new(
            carrier => $_->{carrier},
            rate => $_->{rate},
            service => $_->{service}
        )                                   } @{ $rates };

}

sub buy_label {
    my $self = shift;

    my $resp = $self->post('/postage/buy', merge( map { $_->serialize } @_ ) );

    return Net::Easypost::Label->new(
        rate => $resp->{rate},
        tracking_code => $resp->{tracking_code},
        filename => $resp->{label_file_name},
        filetype => $resp->{label_file_type},
        url => $resp->{label_url}
    );
}

sub get_label {
    my $self = shift;

    my $resp = $self->post('/postage/get', { label_file_name => $_[0] } );

    return Net::Easypost::Label->new(
        rate => $resp->{rate},
        tracking_code => $resp->{tracking_code},
        filename => $resp->{label_file_name},
        filetype => $resp->{label_file_type},
        url => $resp->{label_url}
    );
}

sub list_labels {
    my $self = shift;

    my $resp = $self->get($self->_build_url('/postage/list'));

    return $resp->json;
}

1;
