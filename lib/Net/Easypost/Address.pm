package Net::Easypost::Address;

use 5.014;
use Moo;

has 'address1' => (
    is => 'rw',
);

has 'address2' => (
    is => 'rw',
);

has 'city' => (
    is => 'rw',
);

has 'state' => (
    is => 'rw',
);

has 'zip' => (
    is => 'rw',
);

has 'role' => (
    is => 'ro',
    required => 1,
    lazy => 1,
    default => sub { 'address' }
);

sub serialize {
    my $self = shift;

    # want a hash of e.g., address[address1] => foo from all defined attributes 
    my %h = map { $self->role . "[$_]" => $self->$_ } 
        grep { defined $self->$_ } qw(address1 address2 city state zip);

    return \%h;
}

sub clone {
    my $self = shift;

    return $self->new(
        map { $_ => $self->$_ } grep { defined $self->$_ } qw(address1 address2 city state zip)
    );
}

1;
