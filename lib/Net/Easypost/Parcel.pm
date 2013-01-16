package Net::Easypost::Parcel;

use 5.014;
use Moo;

# ABSTRACT: An object to represent an Easypost parcel

=attr length

The length of the parcel in inches.

=cut

has 'length' => (

    is => 'rw',
);

=attr width

The width of the parcel in inches.

=cut

has 'width' => (
    is => 'rw',
);

=attr height

The height of the parcel in inches.

=cut 

has 'height' => (
    is => 'rw',
);

=attr weight

The weight of the parcel in ounces. (There are 16 ounces in a U.S. pound.)

=cut

has 'weight' => (
    is => 'rw',
);

=attr predefined_package

A carrier specific flat-rate package name. See L<https://www.geteasypost.com/api> for these.

=cut

has 'predefined_package' => (
    is => 'rw',
);

=method serialize

Format this object into a form suitable for use with the Easypost service.

=cut

sub serialize {
    my $self = shift;
    my $role = shift // 'parcel';

    # want a hash of e.g., parcel[address1] => foo from all defined attributes 
    my %h = map { $role . "[$_]" => $self->$_ } 
        grep { defined $self->$_ } qw(length width height weight predefined_package);

    return \%h;
}

=method clone

Make a new copy of this object.

=cut

sub clone {
    my $self = shift;

    return $self->new(
        map { $_ => $self->$_ } grep { defined $self->$_ } qw(length width height weight predefined_package)    
    );
}

1;
