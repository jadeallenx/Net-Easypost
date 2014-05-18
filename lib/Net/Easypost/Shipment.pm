package Net::Easypost::Shipment;

use Carp qw(croak);
use Data::Dumper;
use Moo;
use Types::Standard qw(ArrayRef HashRef InstanceOf Str);

with qw(Net::Easypost::PostOnBuild);
with qw(Net::Easypost::Resource);

=attr to_address

Address this Shipment is going to

=cut

has to_address => (
   is       => 'ro',
   isa      => InstanceOf['Net::Easypost::Address'],
   required => 1,
);

=attr from_address

Address this Shipment is coming from

=cut

has from_address => (
   is       => 'ro',
   isa      => InstanceOf['Net::Easypost::Address'],
   required => 1,
);

=attr parcel

Parcel that is being shipped

=cut

has parcel => (
   is       => 'rw',
   isa      => InstanceOf['Net::Easypost::Parcel'],
   required => 1,
);

=attr customs_info

Customs information about this Shipment, optional (only for international shipments)

=cut

has customs_info => (
   is  => 'rw',
   isa => InstanceOf['Net::Easypost::CustomsInfo'],
);

=attr scan_form

USPS Tracking information, optional

=cut

has scan_form => (
   is  => 'rw',
   isa => InstanceOf['Net::Easypost::ScanForm'],
);

=attr rates

Array of Net::Easypost::Rate objects

=cut

has rates => (
   is  => 'rwp',
   isa => ArrayRef[ InstanceOf['Net::Easypost::Rate'] ],
);

=attr options

Array of shipping options, may not be supported by all carriers

=cut

has options => (
   is  => 'rw',
   isa => HashRef[Str],
);

=method _build_fieldnames

Attributes that make up an Address, from L<Net::Easypost::Resource>

=cut

sub _build_fieldnames { [qw(to_address from_address parcel customs_info scan_form rates options)] }

=method _build_role

Prefix to data when POSTing to the Easypost API about Address objects

=cut

sub _build_role { 'shipment' }

=method _build_operation

Base API endpoint for operations on Address objects

=cut

sub _build_operation { '/shipments' }

=method BUILD

Constructor for a Shipment object, overrides the base BUILD method in L<Net::Easypost::PostOnBuild>

=cut

sub BUILD {}
after BUILD => sub {
   my $self = shift;

   my $resp = $self->requester->post(
      $self->operation,
      $self->serialize,
   );
   $self->_set_id( $resp->{id} );
   $self->_set_rates(
      [  map {
            Net::Easypost::Rate->new(
               id          => $_->{id},
               carrier     => $_->{carrier},
               service     => $_->{service},
               rate        => $_->{rate},
               shipment_id => $self->id,
            )
         } @{ $resp->{rates} }
      ]
   );
};

=method serialize

Format this object into a form suitable for use with the Easypost service.
Overrides base implementation in L<Net::Easypost::PostOnBuild>

=cut

sub serialize {
   my $self = shift;

   # want a hashref of e.g., shipment[to_address][id] => foo from all defined attributes
   return {
      map { $self->role . "[$_][id]" => $self->$_->id }
         grep { defined $self->$_ }
            qw(to_address from_address parcel)
   };
}

sub clone {
   my $self = shift;

   return Net::Easypost::Shipment->new(
      map { $_ => $self->$_ }
         grep { defined $self->$_ }
            'id', $self->fieldnames
   );
}

sub buy {
   my ($self, %options) = @_;

   my $rate; 
   if ( exists $options{rate} && $options{rate} eq 'lowest' ) {
      ($rate) = 
         sort { $a->{rate} <=> $b->{rate} } @{$self->rates};
   } 
   elsif ( exists $options{service_type} ) {
      ($rate) =
         grep { $options{service_type} eq $_->service } @{$self->rates};
   }
   else {
      croak "Missing 'service' or 'rate' from options hash";
   }

   if ( !$rate ) {
      my $msg = "Allowed services and rates for this shipment are:\n";
      foreach my $rate ( @{$self->rates} ) {
         $msg .= sprintf("\t%-15s: %4.2f\n", $rate->service, $rate->rate);
      }

      croak "Invalid service '$options{service_type}' selected for shipment " . $self->id . "\n$msg";
   }

   my $response = $self->requester->post(
      $self->operation . '/' . $self->id . '/buy',
      $rate->serialize
   );

   my $label = $response->{postage_label};
   return Net::Easypost::Label->new(
      id            => $label->{id},
      tracking_code => $response->{tracking_code},
      url           => $label->{label_url},
      filetype      => $label->{label_file_type},
      filename      => 'EASYPOST_LABEL_'
                        . $label->{id}
                        . '.'
                        . substr($label->{label_file_type}, index($label->{label_file_type}, '/') + 1),
   );
}

1;
