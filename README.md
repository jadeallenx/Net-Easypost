# NAME

Net::Easypost - Perl client for the Easypost web service

# VERSION

version 0.10

# SYNOPSIS

   use Net::Easypost;

   my $to = Net::Easypost::Address->new(
      name    => 'Johnathan Smith',
      street1 => '710 East Water Street',
      city    => 'Charlottesville',
      state   => 'VA',
      zip     => '22902',
      phone   => '(434)555-5555',
   );

   my $from = Net::Easypost::Address->new(
      name    => 'Jarrett Streebin',
      phone   => '3237078576',
      city    => 'Half Moon Bay',
      street1 => '310 Granelli Ave',
      state   => 'CA',
      zip     => '94019',
   );

   my $parcel = Net::Easypost::Parcel->new(
      length => 10.0,
      width  => 5.0,
      height => 8.0,
      weight => 10.0,
   );

   my $shipment = Net::Easypost::Shipment->new(
      to_address   => $to,
      from_address => $from,
      parcel       => $parcel,
   );

   my $ezpost = Net::Easypost->new;
   my $label = $ezpost->buy_label($shipment, ('rate' => 'lowest'));

   printf("You paid \$%0.2f for your label to %s\n", $label->rate->rate, $to);
   $label->save;
   printf "Your postage label has been saved to '" . $label->filename . "'\n";

# OVERVIEW

This is a Perl client for the postage API at [Easypost](https://www.geteasypost.com). Consider this
API at beta quality mostly because some of these library calls have an inconsistent input
parameter interface which I'm not super happy about. Still, there's enough here to get 
meaningful work done, and any future changes will be fairly cosmetic.

At this time, Easypost only supports United States based addresses.

Please note! __All API errors are fatal via croak__. If you need to catch errors more gracefully, I 
recommend using [Try::Tiny](http://search.cpan.org/perldoc?Try::Tiny) in your implementation.

# ATTRIBUTES

## access\_code

This is the Easypost API access code which the client will use to authenticate
calls to various endpoints. This is a required attribute which must be supplied
at object instantiation time.

# METHODS

## verify\_address

This method attempts to validate an address. This call expects to take the same parameters 
(in a hashref) or an instance of [Net::Easypost::Address](http://search.cpan.org/perldoc?Net::Easypost::Address), namely:

- street1
- street2
- city
- state
- zip

You may omit some of these attributes like city, state if you supply a zip, or
zip if you supply a city, state. 

This call returns a new [Net::Easypost::Address](http://search.cpan.org/perldoc?Net::Easypost::Address) object.

Along with the validated address, the `phone` and `name` fields will be
copied from the input parameters, if they're set.

## get\_rate

This method will get postage rates between two zip codes. It takes the following input parameters:

- to => an instance of [Net::Easypost::Address](http://search.cpan.org/perldoc?Net::Easypost::Address) with a zip in the "to" role
- from => an instance of [Net::Easypost::Address](http://search.cpan.org/perldoc?Net::Easypost::Address) with a zip in the "from" role
- parcel => an instance of [Net::Easypost::Parcel](http://search.cpan.org/perldoc?Net::Easypost::Parcel)

This call returns an array of [Net::Easypost::Rate](http://search.cpan.org/perldoc?Net::Easypost::Rate) objects in an arbitrary order.

## buy\_label

This method will attempt to purchase postage and generate a shipping label.

It takes as input:

- A [Net::Easypost::Address](http://search.cpan.org/perldoc?Net::Easypost::Address) object in the "to" role,
- A [Net::Easypost::Address](http://search.cpan.org/perldoc?Net::Easypost::Address) object in the "from" role,
- A [Net::Easypost::Parcel](http://search.cpan.org/perldoc?Net::Easypost::Parcel) object
- A [Net::Easypost::Rate](http://search.cpan.org/perldoc?Net::Easypost::Rate) object

It returns a [Net::Easypost::Label](http://search.cpan.org/perldoc?Net::Easypost::Label) object.

## get\_label

This method retrieves a label from a past purchase. It takes the label filename as its 
only input parameter. It returns a [Net::Easypost::Label](http://search.cpan.org/perldoc?Net::Easypost::Label) object.

## list\_labels

This method returns an arrayref with all past purchased label filenames. It takes no
input parameters.

# SUPPORT

Please report any bugs or feature requests to "bug-net-easypost at
rt.cpan.org", or through the web interface at
[http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Net-Easypost](http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Net-Easypost).  I will
be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

Or, if you wish, you may report bugs/features on Github's Issue Tracker.
[https://github.com/mrallen1/Net-Easypost/issues](https://github.com/mrallen1/Net-Easypost/issues)

# SEE ALSO

- [Easypost API docs](https://www.geteasypost.com/api)

# AUTHOR

Mark Allen <mrallen1@yahoo.com>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Mark Allen.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
