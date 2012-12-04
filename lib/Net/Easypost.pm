package Net::Easypost;

use 5.014;

use Moo;
use Hash::Merge::Simple qw(merge);
use Carp qw(croak);

use Net::Easypost::Address;
use Net::Easypost::Parcel;
use Net::Easypost::Rate;
use Net::Easypost::Label;

with('Net::Easypost::Request');

# ABSTRACT: Perl client for the Easypost.co service

=head1 SYNOPSIS

  use 5.014;
  use Net::Easypost;

  my $ezp = Net::Easypost->new(
        access_code => 'sekrit'
  );

  $addr = $ezp->verify_address( {
        street1 => '101 Spear St',
        city => 'San Francisco',
        zip => '94107'
  } );

  my $to = $addr->clone;
  $to->role('to');
  $to->name('Mr Spacely');

  my $from = Net::Easypost::Address->new(
        role => 'from',
        name => 'George Jetson',
        street1 => '1060 W Addison',
        city => 'Chicago',
        state => 'IL',
        phone => '3125559797',
        zip => '60657'
  );

  my $parcel = Net::Easypost::Parcel->new(
        length => 10.0, # dimensions in inches
        width => 12.0,  
        height => 5.0, 
        weight => 13.0, # weight in ounces
  );

  my $service = Net::Easypost::Rate->new(
        service => 'Priority',
  );

  my $label = $ezp->buy_label(
        $to,
        $from,
        $parcel,
        $service
  );

  printf("You paid $0.2f for your label to %s\n", $label->rate->rate, $to);
  $label->save;
  say ("Your postage label has been saved to ", $label->filename);

=head1 OVERVIEW

This is a Perl client for the postage API at L<Easypost|https://www.easypost.co>. Consider this
API at beta quality mostly because some of these library calls have an inconsistent input
parameter interface which I'm not super happy about. Still, there's enough here to get 
meaningful work done, and any future changes will be fairly cosmetic.

At this time, Easypost only supports United States based addresses.

Please note! B<All API errors are fatal via croak>. If you need to catch errors more gracefully, I 
recommend using L<Try::Tiny> in your implementation.

=cut

=attr access_code

This is the Easypost API access code which the client will use to authenticate
calls to various endpoints. This is a required attribute which must be supplied
at object instantiation time.

=cut

has 'access_code' => (
    is => 'ro',
    required => 1,
);

=method verify_address

This method attempts to validate an address. This call expects to take the same parameters 
(in a hashref) or an instance of L<Net::Easypost::Address>, namely:

=over

=item * street1

=item * street2

=item * city

=item * state

=item * zip

=back

You may omit some of these attributes like city, state if you supply a zip, or
zip if you supply a city, state. 


This call returns a new L<Net::Easypost::Address> object.

Along with the validated address, the C<phone> and C<name> fields will be
copied from the input parameters, if they're set.

=cut

sub verify_address {
    my $self = shift;
    my $params = shift;

    my $address;
    if ( ref($params) eq 'HASH' ) {
        $address = Net::Easypost::Address->new( $params );
    }
    elsif ( ref($params) eq 'Net::Easypost::Address' ) {
        $address = $params;
    }
    else {
        croak 'verify_address expects either a hashref or an instance of Net::Easypost::Address\n';
    }

    my $new = Net::Easypost::Address->new(
        $self->post(
            '/address/verify', 
            $address->serialize([qw(street1 street2 city state zip)])
        )->{'address'}
    );

    return $new->merge($address, [qw(phone name role)]);

}

=method get_rate

This method will get postage rates between two zip codes. It takes the following input parameters:

=over

=item * to => an instance of L<Net::Easypost::Address> with a zip in the "to" role

=item * from => an instance of L<Net::Easypost::Address> with a zip in the "from" role

=item * parcel => an instance of L<Net::Easypost::Parcel>

=back

This call returns an array of L<Net::Easypost::Rate> objects in an arbitrary order.

=cut

sub get_rates {
    my $self = shift;

    my $params;
    if ( scalar @_ == 1 && ref( $params = shift ) ne 'HASH' ) {
        # we did the assignment here ^^^^ so if this is *not* a hashref, croak 
        croak 'get_rates expects a hashref not a '. ref($params) .'\n';
    }
    else {
        $params = { @_ };
    }

    my $to = delete $params->{to};

    croak $to->as_string . ' is not in the "to" role\n' if $to->role ne 'to';
    
    my $from = delete $params->{from};

    croak $from->as_string . ' is not in the "from" role\n' if $from->role ne 'from';

    my $parcel = delete $params->{parcel};

    my $rates = $self->post('/postage/rates', merge(
        $to->serialize(['zip']),
        $from->serialize(['zip']),
        $parcel->serialize)
    )->{'rates'};

    return map { 
        Net::Easypost::Rate->new(
            carrier => $_->{carrier},
            rate => $_->{rate},
            service => $_->{service}
        )                                   } @{ $rates };

}

=method buy_label

This method will attempt to purchase postage and generate a shipping label.

It takes as input:

=over

=item * A L<Net::Easypost::Address> object in the "to" role,

=item * A L<Net::Easypost::Address> object in the "from" role,

=item * A L<Net::Easypost::Parcel> object

=item * A L<Net::Easypost::Rate> object

=back

It returns a L<Net::Easypost::Label> object.

=cut

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

=method get_label

This method retrieves a label from a past purchase. It takes the label filename as its 
only input parameter. It returns a L<Net::Easypost::Label> object.

=cut

sub get_label {
    my $self = shift;

    my $resp = $self->post('/postage/get', { label_file_name => $_[0] } );

    return Net::Easypost::Label->new(
        rate => Net::Easypost::Rate->new($resp->{rate}),
        tracking_code => $resp->{tracking_code},
        filename => $resp->{label_file_name},
        filetype => $resp->{label_file_type},
        url => $resp->{label_url}
    );
}

=method list_labels

This method returns an arrayref with all past purchased label filenames. It takes no
input parameters.

=cut

sub list_labels {
    my $self = shift;

    my $resp = $self->get($self->_build_url('/postage/list'));

    return $resp->json->{'postages'};
}

=head1 SUPPORT

Please report any bugs or feature requests to "bug-net-easypost at
rt.cpan.org", or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Net-Easypost>.  I will
be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

Or, if you wish, you may report bugs/features on Github's Issue Tracker.
L<https://github.com/mrallen1/Net-Easypost/issues>

=head1 SEE ALSO

=over

=item * L<Easypost API docs|https://www.easypost.co/api>

=back

=cut

1;
