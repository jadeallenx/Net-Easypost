package Net::Easypost::Parcel;

use Moo;

with qw(Net::Easypost::PostOnBuild);
with qw(Net::Easypost::Resource);

# ABSTRACT: An object to represent an Easypost parcel

=attr length

The length of the parcel in inches.

=cut

has length => (
    is => 'rw',
);

=attr width

The width of the parcel in inches.

=cut

has width => (
    is => 'rw',
);

=attr height

The height of the parcel in inches.

=cut

has height => (
    is => 'rw',
);

=attr weight

The weight of the parcel in ounces. (There are 16 ounces in a U.S. pound.)

=cut

has weight => (
    is => 'rw',
);

=attr predefined_package

A carrier specific flat-rate package name. See L<https://www.easypost.com/docs/api/#predefined-packages> for these.

=cut

has predefined_package => (
    is => 'rw',
);

=method _build_fieldnames

Attributes that make up an Parcel, from L<Net::Easypost::Resource>

=cut

sub _build_fieldnames { [qw(length width height weight predefined_package)] }

=method _build_role

Prefix to data when POSTing to the Easypost API about Parcel objects

=cut

sub _build_role { 'parcel' }

=method _build_operation

Base API endpoint for operations on Address objects

=cut

sub _build_operation { '/parcels' }

=method clone

returns a new Net::Easypost::Parcel object that is a deep-copy of this object

=cut

sub clone {
    my $self = shift;

    return Net::Easypost::Parcel->new(
        map { $_ => $self->$_ }
            grep { defined $self->$_ }
                'id', $self->fieldnames
    );
}

1;
