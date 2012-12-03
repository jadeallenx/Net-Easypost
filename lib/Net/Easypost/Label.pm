package Net::Easypost::Label;

use 5.014;
use Moo;
use Carp qw(croak);
use IO::Handle;

with('Net::Easypost::Request');

has 'tracking_code' => (
    is => 'ro',
);

has 'filename' => (
    is => 'ro',
);

has 'filetype' => (
    is => 'ro',
    lazy => 1,
    default => sub { 'image/png' }
);

has 'url' => (
    is => 'ro',
    predicate => 1,
);

has 'rate' => (
    is => 'ro',
);

has 'image' => (
    is => 'ro',
    lazy => 1,
    predicate => 1,
    default => sub {
        my $self = shift;

        croak "can't retrieve image for " . $self->filename . 
            " without a url" unless $self->has_url; 

        return $self->get($self->url);
    }
);

sub save {
    my $self = shift;

    croak "can't save label " . $self->filename . 
        " there's image data" unless $self->has_image;

    open my $fh, ">:raw", $self->filename or croak "Couldn't save " . $self->filename . ": $!";
    print $fh $self->image;
    $fh->close;

}

1;
