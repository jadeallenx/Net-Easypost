#!/usr/bin/perl

use strict;
use Test::More;
use Data::Printer;

use 5.014;

if (!eval { require Socket; Socket::inet_aton('www.easypost.co') }) {
    plan skip_all => "Cannot connect to the API server";
} 

# 60 second connection timeout
$ENV{MOJO_CONNECT_TIMEOUT} = 60;

plan tests => 14;

use Net::Easypost;

my $ezpost = Net::Easypost->new( access_code => 'cueqNZUb3ldeWTNX7MU3Mel8UXtaAMUi' );
isa_ok($ezpost, 'Net::Easypost', 'object created');

my $addr = $ezpost->verify_address( {
        street1 => '388 Townsend St', 
        street2 => 'Apt 20', 
        city => 'San Francisco',
        zip => '94107',
        name => 'Zaphod'
} );

is($addr->state, 'CA', 'got right state');
is($addr->name, 'Zaphod', 'name copied');
like(sprintf($addr), qr/Zaphod\n/xms, 'address stringified');

use Net::Easypost::Address;
use Net::Easypost::Parcel;

my @rates = $ezpost->get_rates(
          to => Net::Easypost::Address->new( role => 'to', zip => '94107'),
        from => Net::Easypost::Address->new( role => 'from', zip => '94019'), 
      parcel => Net::Easypost::Parcel->new ( 
          length => 10.0, 
          width => 5.0,
          height => 8.0,
          weight => 100.0
      )
);

cmp_ok(scalar @rates, '>', 4, 'got more than 4 rates');
isa_ok($rates[0], 'Net::Easypost::Rate', 'element correctly');
like($rates[0]->carrier, qr/USPS|UPS|FedEx/, 'carrier is correct');

use Net::Easypost::Rate;

my $to = $addr->clone;
$to->role('to');
$to->name('Jon Calhoun');

my $from = Net::Easypost::Address->new(
    role => 'from',
    name => 'Jarrett Streebin',
    phone => '3237078576',
    city => 'Half Moon Bay',
    street1 => '310 Granelli Ave',
    state => 'CA',
    zip => '94019',
);

my $parcel = Net::Easypost::Parcel->new(
    length => 10.0,
    width => 5.0,
    height => 8.0,
    weight => 10.0,
);

my $rate = Net::Easypost::Rate->new(
    service => 'Priority',
);

my $label = $ezpost->buy_label($to, $from, $parcel, $rate);

is($label->has_url, 1, 'has url!');
is($label->has_image, '', 'has no image');
my $image_size = length $label->image;
is($image_size > 1000, 1, 'image is 1k or more');
is($label->has_image, 1, 'has image');
like($label->filename, qr/\.png/, 'got png again!');
like($label->tracking_code, qr/[0-9]+/, 'got correct test tracking code');
$label->save;
is(-e $label->filename, 1, 'image file exists');

unlink $label->filename;
