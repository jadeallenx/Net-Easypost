package Net::Easypost::Parcel;

use 5.014;
use Moo;

# dimensions are in inches
has 'length' => (

    is => 'rw',
);

has 'width' => (
    is => 'rw',
);

has 'height' => (
    is => 'rw',
);

# weight is in ounces
has 'weight' => (
    is => 'rw',
);

has 'predefined_package' => (
    is => 'rw',
);

sub serialize {
    my $self = shift;
    my $role = shift // 'parcel';

    # want a hash of e.g., parcel[address1] => foo from all defined attributes 
    my %h = map { $role . "[$_]" => $self->$_ } 
        grep { defined $self->$_ } qw(length width height weight);

    return \%h;
}

sub clone {
    my $self = shift;

    return $self->new(
        map { $_ => $self->$_ } grep { defined $self->$_ } qw(length width height weight)    
    );
}

1;
