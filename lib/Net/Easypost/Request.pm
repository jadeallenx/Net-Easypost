package Net::Easypost::Request;

use Carp qw(croak);
use Data::Dumper;
use Mojo::UserAgent;
use Moo;

=attr ua

A user agent attribute. Defaults to L<Mojo::UserAgent>.

=cut

has user_agent => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        my $user_agent = Mojo::UserAgent->new;
        $user_agent->transactor->name(
            'Net::Easypost (Perl)/' . $Net::Easypost::VERSION
        );

        return $user_agent;
    },
);

=attr endpoint

The Easypost service endpoint. Defaults to 'https://api.easypost.com/v2'

=cut

has endpoint => (
    is      => 'ro',
    lazy    => 1,
    default => sub { 'api.easypost.com/v2' }
);

=method post

This method uses the C<ua> attribute to generate a form post request. It takes
an endpoint URI fragment and the parameters to be sent.  It returns JSON deserialized
into Perl structures.

=cut

sub post {
    my ($self, $operation, $params) = @_;

    my $tx = $self->user_agent->post(
        $self->_build_url($operation),
        form => $params,
    );

    if ( !$tx->success ) {
        my ($err, $code) = $tx->error;
        croak $code ? "FATAL: " . $self->endpoint . $operation . " returned $code: '$err'" :
                      "FATAL: " . $self->endpoint . $operation . " returned '$err'";
    }

    return $tx->res->json;
}

=method _build_url

Given an operation, constructs a valid Easypost URL using the specified
EASYPOST_API_KEY

=cut

sub _build_url {
    my ($self, $operation) = @_;

    if ( exists $ENV{EASYPOST_API_KEY} ) {
        return 'https://' . $ENV{EASYPOST_API_KEY} . ':@' . $self->endpoint . $operation;
    }
    else {
        croak 'Cannot find API key in access_code attribute of Net::Easypost' 
            . ' or in an environment variable name EASYPOST_API_KEY';
    }
}

=method get

This method uses the C<ua> attribute to generate a GET request to an endpoint. It
takes a complete endpoint URI as its input and returns a L<Mojo::Message::Response>
object.

=cut

sub get {
    my ($self, $endpoint) = @_;

    $endpoint = $self->_build_url($endpoint)
        unless $endpoint =~ m/https?/;

    return $self->user_agent->get(
        $endpoint
    )->res;
}

1;
