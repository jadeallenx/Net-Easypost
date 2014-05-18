package Net::Easypost::Label;

use Carp qw(croak);
use IO::Handle;
use Moo;
use Net::Easypost::Request;

with qw(Net::Easypost::Resource);

=attr tracking_code

The carrier generated tracking code for this label.

=cut

has tracking_code => (
    is       => 'ro',
    required => 1
);

=attr filename

The filename the Easypost API used to create the label file. (Also used
for local storage.)

=cut

has filename => (
    is       => 'ro',
    required => '1',
);

=attr filetype

The file type for the image data. Defaults to 'image/png'

=cut

has filetype => (
    is      => 'ro',
    lazy    => 1,
    default => sub { 'image/png' }
);

=attr url

The URL from which to download the label image.

=cut

=method has_url

This is a predicate which tells the caller if a URL is defined in the object.

=cut

has url => (
    is        => 'ro',
    predicate => 1,
    required  => 1,
);


=attr image

This is the label image data.  It lazily downloads this information if a
URL is defined. It currently uses a L<Net::Easypost::Request> role to
get the data from the Easypost service.

=cut

=method has_image

Tells the caller if an image has been downloaded.

=cut

has image => (
    is        => 'ro',
    lazy      => 1,
    predicate => 1,
    default   => sub {
        my $self = shift;

        croak "can't retrieve image for " . $self->filename . " without a url"
            unless $self->has_url;

        return $self->requester->get($self->url)->content->asset->slurp;
    }
);

sub _build_role { 'label' }
sub _build_fieldnames { [qw(tracking_code url filetype filename)] }


=method save

Store the label image locally using the filename in the object. This will typically be
in the current working directory of the caller.

=cut

sub save {
    my $self = shift;

    $self->image
        unless $self->has_image;

    open my $fh, ">:raw", $self->filename
        or croak "Couldn't save " . $self->filename . ": $!";

    print {$fh} $self->image;
    $fh->close;
}

=method clone

returns a new Net::Easypost::Label object that is a deep-copy of this object

=cut

sub clone {
   my $self = shift;

   return Net::Easypost::Label->new(
      map { $_ => $self->$_ }
         grep { defined $self->$_ }
            'id', @{ $self->fieldnames }
   );
}

=method serialize

serialized form for Label objects

=cut

sub serialize {
   my $self = shift;

   # want a hashref of e.g., role[field1] => foo from all defined attributes
   return {
      map { $self->role . "[$_]" => $self->$_ }
         grep { defined $self->$_ }
            @{ $self->fieldnames }
   };
}

1;
