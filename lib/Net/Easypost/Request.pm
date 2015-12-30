package Net::Easypost::Request;

use Moo;

use Carp qw(croak);
use Mojo::UserAgent;

has 'user_agent' => (
    is      => 'ro',
    default => sub {
        my $user_agent = Mojo::UserAgent->new;
        $user_agent->transactor->name(
            'Net::Easypost (Perl)/' . $Net::Easypost::VERSION
        );

        return $user_agent;
    },
);

has 'endpoint' => (
    is      => 'ro',
    default => 'api.easypost.com/v2',
);

sub post {
    my ($self, $operation, $params) = @_;

    my $tx = $self->user_agent->post(
        $self->_build_url($operation),
        form => $params,
    );

    unless ( $tx->success ) {
        my ($err, $code) = $tx->error;
        croak $code ? "FATAL: " . $self->endpoint . $operation . " returned $code: '$err'" :
                      "FATAL: " . $self->endpoint . $operation . " returned '$err'";
    }

    return $tx->res->json;
}

sub get {
    my ($self, $endpoint) = @_;

    $endpoint = $self->_build_url($endpoint)
        unless $endpoint =~ m/https?/;

    return $self->user_agent->get(
        $endpoint
    )->res;
}

sub _build_url {
    my ($self, $operation) = @_;

    return 'https://' . $ENV{EASYPOST_API_KEY} . ':@' . $self->endpoint . $operation 
        if exists $ENV{EASYPOST_API_KEY};
 
    croak 'Cannot find API key in access_code attribute of Net::Easypost' 
        . ' or in an environment variable name EASYPOST_API_KEY';
}

1;

__END__

=pod 

=head1 NAME 

Net::Easypost::Request

=head1 SYNOPSIS

Net::Easypost::Request->new

=head1 ATTRIBUTES 

=over 4 

=item user_agent

A user agent attribute. Defaults to L<Mojo::UserAgent>.

=item endpoint

The Easypost service endpoint. Defaults to 'https://api.easypost.com/v2'

=back

=head1 METHODS 

=over 4 

=item _build_url

Given an operation, constructs a valid Easypost URL using the specified
EASYPOST_API_KEY

=item post

This method uses the C<user_agent> attribute to generate a form post request. It takes
an endpoint URI fragment and the parameters to be sent.  It returns JSON deserialized
into Perl structures.

=item get

This method uses the C<user_agent> attribute to generate a GET request to an endpoint. It
takes a complete endpoint URI as its input and returns a L<Mojo::Message::Response>
object.

=back

=cut 
