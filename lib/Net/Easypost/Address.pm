package Net::Easypost::Address;

use 5.014;
use Moo;

has 'street1' => (
    is => 'rw',
);

has 'street2' => (
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

has 'order' => (
    is => 'ro',
    lazy => 1,
    default => sub { [qw(street1 street2 city state zip)] }
);

sub serialize {
    my $self = shift;

    # want a hash of e.g., address[address1] => foo from all defined attributes 
    my %h = map { $self->role . "[$_]" => $self->$_ } 
        grep { defined $self->$_ } @{$self->order};

    return \%h;
}

sub clone {
    my $self = shift;

    return $self->new(
        map { $_ => $self->$_ } grep { defined $self->$_ } @{$self->order}
    );
}

sub as_string {
    my $self = shift;

    join "\n", 
        (map { $self->$_ } grep { defined $self->$_ } qw(street1 street2)),
        join " ", map { $self->$_ } grep { defined $self->$_ } qw(city state zip)
        ;
}

1;
