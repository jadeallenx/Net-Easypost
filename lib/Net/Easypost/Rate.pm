package Net::Easypost::Rate;

use Moo;

with qw(Net::Easypost::Resource);

=attr carrier

The shipping carrier. At the current time, the United States Postal Service (USPS) is the only
supported carrier.

=cut

has carrier => (
  is      => 'ro',
  lazy    => 1,
  default => sub { 'USPS' },
);

=attr service

The shipping service name. For example, for the USPS, these include 'Priority', 'Express',
'Media Mail' and others.

=cut

has service => (
  is => 'ro',
);

=attr rate

The price in US dollars to ship using the associated carrier and service.

=cut

has rate => (
  is => 'ro',
);

=attr shipment_id

ID of the shipment that this Rate object relates to

=cut

has shipment_id => (
  is => 'ro',
);

sub _build_fieldnames { [qw(carrier service rate shipment_id)] }
sub _build_role { 'rate' }

=method serialize

serialized form of Rate objects

=cut

sub serialize {
   my $self = shift;

   return { 'rate[id]' => $self->id };
}

=method clone

returns a new Rate object that is a deep-copy of this Rate object

=cut

sub clone {
   my $self = shift;

   return Net::Easypost::Rate->new(
      map { $_ => $self->$_ }
         grep { defined $self->$_ }
            'id', @{ $self->fieldnames }
   );
}

1;
