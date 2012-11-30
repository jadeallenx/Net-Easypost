package Net::Easypost::Carrier;

use 5.014;
use Moo;

has 'carrier' => (
    is => 'ro',
    lazy => 1,
    default => sub { 'USPS' }
);

1;

