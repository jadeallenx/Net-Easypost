#!/usr/bin/perl

use strict;
use Test::More;

use 5.014;

if (!eval { require Socket; Socket::inet_aton('www.easypost.co') }) {
    plan skip_all => "Cannot connect to the API server";
} 

# 60 second connection timeout
$ENV{MOJO_CONNECT_TIMEOUT} = 60;

plan tests => 1;

use Net::Easypost;
use Net::Easypost::Address;
use Net::Easypost::Parcel;

my $ezpost = Net::Easypost->new( access_code => 'cueqNZUb3ldeWTNX7MU3Mel8UXtaAMUi' );

my $addr = $ezpost->verify_address( {
        street1 => '1776 Yorktown St', 
        street2 => 'Suite 700', 
        city => 'Houston',
        zip => '77056',
        name => 'Zaphod Beeblebrox'
} );

my $to = $addr->clone;
$to->role('to');
$to->name('Bob Jones');

my $from = Net::Easypost::Address->new(
        role => 'from',
        name => 'Time Capsule Corporation',
        street1 => '1004 N Railroad Street',
        street2 => 'PO Box 38',
        city => 'Shirley',
        state => 'IN',
        phone => '3178918463',
        zip => '47384'
);

my $parcel = Net::Easypost::Parcel->new(
        length => 10, # dimensions in inches
        width => 5,
        height => 8,
        weight => 100, # weight in ounces
);

my @rates = $ezpost->get_rates( {
          to => $to,
        from => $from,
      parcel => $parcel,
    }
);

cmp_ok(scalar @rates, '>', 4, 'got more than 4 rates using hashref');
