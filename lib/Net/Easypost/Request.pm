package Net::Easypost::Request;

use 5.014;

use Moo::Role;
use Mojo::UserAgent;
use Carp qw(croak);
use Data::Printer;

has ua => (
    is => 'ro',
    lazy => 1,
    default => sub {
        my $ua = Mojo::UserAgent->new();
        $ua->name('Net::Easypost (Perl)/' . $Net::Easypost::VERSION);
    },
);

has endpoint => (
    is => 'ro',
    lazy => 1,
    default => sub { 'www.easypost.co/api' }
);

sub post {
    my $self = shift;
    my $operation = shift;
    my $params = shift;

    my $tx = $self->ua->post_form(
        $self->_build_url($operation), 
        $params, 
    );

    my $json = $tx->res->json;

    croak "FATAL: " . $json->{error} if exists $json->{error};

    return $json;
}

sub _build_url {
    my $self = shift;
    my $operation = shift;

    return "https://" . $self->access_code . ":@" . $self->endpoint . $operation;
}

sub get {
    my $self = shift;
    my $endpoint = shift;

    my $tx = $self->ua->get($endpoint);

    return $tx->res;
}

1;
