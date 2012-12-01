#!/usr/bin/perl

use strict;
use Test::More;
use Data::Printer;

use 5.014;

if (!eval { require Socket; Socket::inet_aton('www.easypost.co') }) {
    plan skip_all => "Cannot connect to the API server";
} 
elsif ( ! $ENV{EASYPOST_ACCESS_CODE} ) {
    plan skip_all => "API credentials required for these tests";
}
else {
    plan tests => 4;
}

#untaint environment variables
my @params = map {my ($v) = $ENV{uc "EASYPOST_$_"} =~ /\A(.*)\z/; $_ => $v} qw(access_code);

use Net::Easypost;

my $ezpost = Net::Easypost->new( @params );
isa_ok($ezpost, 'Net::Easypost', 'object created');

my $addr = $ezpost->verify_address(
        street1 => '388 Townsend St', 
        street2 => 'Apt 20', 
        city => 'San Francisco',
        zip => '94107',
);

is($addr->state, 'CA', 'got right state');

my $rate = $ezpost->get_rates(
        to => '94107', 
        from => '94019', 
        length => 10.0, 
        width => 5.0,
        height => 8.0,
        weight => 100.0
);

is(exists $rate->{USPS}, 1, 'got right carrier');
is(exists $rate->{USPS}->{Express}, 1, 'got right service');


