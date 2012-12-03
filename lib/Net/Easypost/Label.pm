package Net::Easypost::Label;

use 5.014;
use Moo;
use Carp qw(croak);
use IO::Handle;

with('Net::Easypost::Request');

# ABSTRACT: Object represents an Easypost label

=attr tracking_code

The carrier generated tracking code for this label.

=cut

has 'tracking_code' => (
    is => 'ro',
);

=attr filename

The filename the Easypost API used to create the label file. (Also used
for local storage.)

=cut

has 'filename' => (
    is => 'ro',
);

=attr filetype

The file type for the image data. Defaults to 'image/png'

=cut

has 'filetype' => (
    is => 'ro',
    lazy => 1,
    default => sub { 'image/png' }
);

=attr url

The URL from which to download the label image.

=cut

=method has_url

This is a predicate which tells the caller if a URL is defined in the object.

=cut

has 'url' => (
    is => 'ro',
    predicate => 1,
);

=attr rate

This is a L<Net::Easypost::Rate> object associated with the label.

=cut

has 'rate' => (
    is => 'ro',
);

=attr image

This is the label image data.  It lazily downloads this information if a
URL is defined. It currently uses a L<Net::Easypost::Request> role to
get the data from the Easypost service.

=cut

=method has_image

Tells the caller if an image has been downloaded.

=cut

has 'image' => (
    is => 'ro',
    lazy => 1,
    predicate => 1,
    default => sub {
        my $self = shift;

        croak "can't retrieve image for " . $self->filename . 
            " without a url" unless $self->has_url; 

        return $self->get($self->url)->content->asset->slurp;
    }
);

=method save

Store the label image locally using the filename in the object. This will typically be
in the current working directory of the caller.

=cut

sub save {
    my $self = shift;

    $self->image unless $self->has_image;

    open my $fh, ">:raw", $self->filename or croak "Couldn't save " . $self->filename . ": $!";
    print $fh $self->image;
    $fh->close;

}

1;
