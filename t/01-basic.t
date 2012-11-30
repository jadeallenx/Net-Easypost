#!/usr/bin/perl

use strict;
use Test::More;

if (!eval { require Socket; Socket::inet_aton('www.easypost.co') }) {
    plan skip_all => "Cannot connect to the API server";
} 
elsif ( ! $ENV{EASYPOST_ACCESS_CODE} ) {
    plan skip_all => "API credentials required for these tests";
}
else {
    plan tests => 1;
}

#untaint environment variables
my @params = map {my ($v) = $ENV{uc "EASYPOST_$_"} =~ /\A(.*)\z/; $_ => $v} qw(access_code);

use Net::Easypost;

my $ezpost = Net::Easypost->new( @params );
isa_ok($ezpost, 'Net::Easypost', 'object created');

$ezpost->verify_address(
        address1 => '388 Townsend St', 
        address2 => 'Apt 20', 
        city => 'San Francisco',
        zip => '94107',
);

