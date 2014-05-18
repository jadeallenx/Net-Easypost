package Net::Easypost::Resource;

use Carp qw(croak);
use Moo::Role;
use Net::Easypost::Request;

# all Net::Easypost::Resource objects must implementat clone and serialize
requires qw(serialize clone);

=attr id

A unique field that represent this Object to Easypost

=cut

has id => (
   is => 'rwp',
);

=attr endpoint

base API operation endpoint for this Object

=cut

has operation => (
   is      => 'ro',
   lazy    => 1,
   builder => 1,
);

=attr role

Role of this object: address, shipment, parcel, etc...

=cut

has role => (
   is      => 'ro',
   builder => 1,
);

=attr fieldnames

attributes of this Object in the Easypost API

=cut

has fieldnames => (
   is      => 'ro',
   builder => 1,
);

=attr requester

HTTP client to make GET & POST requests

=cut

has requester => (
   is      => 'ro',
   default => sub { Net::Easypost::Request->new },
);

1;
