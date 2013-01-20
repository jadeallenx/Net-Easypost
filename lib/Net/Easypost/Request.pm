package Net::Easypost::Request;

use 5.014;

use Moo::Role;
use Mojo::UserAgent;
use Carp qw(croak);

# ABSTRACT: Request role for Net::Easypost

=attr ua

A user agent attribute. Defaults to L<Mojo::UserAgent>. 

=cut

has ua => (
    is => 'ro',
    lazy => 1,
    default => sub {
        my $ua = Mojo::UserAgent->new();
        $ua->name('Net::Easypost (Perl)/' . $Net::Easypost::VERSION);
    },
);

=attr endpoint

The Easypost service endpoint. Defaults to 'https://www.geteasypost.com/api'

=cut

has endpoint => (
    is => 'ro',
    lazy => 1,
    default => sub { 'www.geteasypost.com/api' }
);

=method post

This method uses the C<ua> attribute to generate a form post request. It takes
an endpoint URI fragment and the parameters to be sent.  It returns JSON deserialized
into Perl structures.

=cut

sub post {
    my $self = shift;
    my $operation = shift;
    my $params = shift;

    my $tx = $self->ua->post_form(
        $self->_build_url($operation), 
        $params, 
    );

    if ( ! $tx->success ) {
        my ($err, $code) = $tx->error;
        croak "FATAL: " . $self->endpoint . $operation . " returned $code: $err";
    }

    return $tx->res->json;
}

sub _build_url {
    my $self = shift;
    my $operation = shift;

    return "https://" . $self->access_code . ":@" . $self->endpoint . $operation;
}

=method get

This method uses the C<ua> attribute to generate a GET request to an endpoint. It
takes a complete endpoint URI as its input and returns a L<Mojo::Message::Response>
object.

=cut

sub get {
    my $self = shift;
    my $endpoint = shift;

    my $tx = $self->ua->get($endpoint);

    return $tx->res;
}

1;
