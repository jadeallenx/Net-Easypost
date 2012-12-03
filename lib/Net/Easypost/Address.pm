package Net::Easypost::Address;

use 5.014;
use Moo;

# ABSTRACT: Class to represent an Easypost address 

=attr street1

A field for street information, typically a house number, a street name and a direction

=cut

has 'street1' => (
    is => 'rw',
);

=attr street2

A field for any additional street information like an apartment or suite number

=cut

has 'street2' => (
    is => 'rw',
);

=attr city

The city in the address

=cut

has 'city' => (
    is => 'rw',
);

=attr state

The U.S. state for this address

=cut

has 'state' => (
    is => 'rw',
);

=attr zip

The U.S. zipcode for this address

=cut

has 'zip' => (
    is => 'rw',
);

=attr phone

Any phone number associated with this address.  Some carrier services like Next-Day or Express
require a sender phone number.

=cut

has 'phone' => (
    is => 'rw',
);

=attr name

A name associated with this address.

=cut

has 'name' => (
    is => 'rw',
);

=attr role

The role of this address. For example, if this is a recipient, it is in the 'to' role.
If it's the sender's address, it's in the 'from' role. Defaults to 'address'.

=cut

has 'role' => (
    is => 'rw',
    required => 1,
    lazy => 1,
    default => sub { 'address' }
);

=attr order

The order attributes should be processed during serialization or cloning. Defaults to
name, street1, street2, city, state, zip, phone.

=cut

has 'order' => (
    is => 'ro',
    lazy => 1,
    default => sub { [qw(name street1 street2 city state zip phone)] }
);

=method serialize

Format the defined attributes for a call to the Easypost service.

=cut

sub serialize {
    my $self = shift;

    # want a hash of e.g., address[address1] => foo from all defined attributes 
    my %h = map { $self->role . "[$_]" => $self->$_ } 
        grep { defined $self->$_ } @{$self->order};

    return \%h;
}

=method clone

Make a new copy of this object and return it.

=cut

sub clone {
    my $self = shift;

    return $self->new(
        map { $_ => $self->$_ } grep { defined $self->$_ } @{$self->order}, 'role'
    );
}

=method as_string

Format this address as it might be seen on a mailing label

=cut

sub as_string {
    my $self = shift;

    join "\n", 
        (map { $self->$_ } grep { defined $self->$_ } qw(name phone street1 street2)),
        join " ", map { $self->$_ } grep { defined $self->$_ } qw(city state zip)
        ;
}

1;
