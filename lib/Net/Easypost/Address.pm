package Net::Easypost::Address;

use Carp qw(croak);
use Moo;
use Scalar::Util;
use overload
   '""' => sub { $_[0]->as_string },
   '0+' => sub { Scalar::Util::refaddr($_[0]) },
   fallback => 1;

with qw(Net::Easypost::PostOnBuild);
with qw(Net::Easypost::Resource);

# ABSTRACT: Class to represent an Easypost address

=attr street1

A field for street information, typically a house number, a street name and a direction

=cut

has street1 => (
    is => 'rw',
);

=attr street2

A field for any additional street information like an apartment or suite number

=cut

has street2 => (
    is => 'rw',
);

=attr city

The city in the address

=cut

has city => (
    is => 'rw',
);

=attr state

The U.S. state for this address

=cut

has state => (
    is => 'rw',
);

=attr zip

The U.S. zipcode for this address

=cut

has zip => (
    is => 'rw',
);

=attr phone

Any phone number associated with this address.  Some carrier services like Next-Day or Express
require a sender phone number.

=cut

has phone => (
    is => 'rw',
);

=attr name

A name associated with this address.

=cut

has name => (
    is => 'rw',
);

=method _build_fieldnames

Attributes that make up an Address, from L<Net::Easypost::Resource>

=cut

sub _build_fieldnames { [qw(name street1 street2 city state zip phone)] }

=method _build_role

Prefix to data when POSTing to the Easypost API about Address objects

=cut

sub _build_role { 'address' }

=method _build_operation

Base API endpoint for operations on Address objects

=cut

sub _build_operation { '/addresses' }

=method clone

Make a new copy of this object and return it.

=cut

sub clone {
    my $self = shift;

    return Net::Easypost::Address->new(
        map { $_ => $self->$_ }
            grep { defined $self->$_ }
                @{ $self->fieldnames }
    );
}

=method as_string

Format this address as it might be seen on a mailing label. This class overloads
stringification using this method, so something like C<say $addr> should just work.

=cut

sub as_string {
    my $self = shift;

    join "\n",
        (map  { $self->$_ }
            grep { defined $self->$_ } qw(name phone street1 street2)),
        join " ",
            (map  { $self->$_ }
                grep { defined $self->$_ } qw(city state zip));
}

=method merge

This method takes a L<Net::Easypost::Address> object and an arrayref of fields to copy
into B<this> object. This method only merges fields that are defined on the other object.

=cut

sub merge {
    my ($self, $old, $fields) = @_;

    map { $self->$_($old->$_) }
        grep { defined $old->$_ }
            @$fields;

    return $self;
}

=method verify

This method takes a L<Net::Easypost::Address> object and verifies its underlying
address

=cut

sub verify {
    my $self = shift;
    use Data::Dumper;

    my $verify_response =
       $self->requester->get( $self->operation . '/' . $self->id . '/verify' );

    croak 'Unable to verify address, failed with message: '
             . $verify_response->{error}
       if $verify_response->{error};

    my $new_address = Net::Easypost::Address->new(
        $verify_response->json->{address}
    );

    return $new_address->merge($self, [qw(phone name)]);
}

1;
