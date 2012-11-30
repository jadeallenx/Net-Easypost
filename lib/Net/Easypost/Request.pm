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

sub send {
    my $self = shift;
    my $operation = shift;
    my $params = shift;
    my $headers = shift;

    my $tx = $self->ua->post_form(
        $self->_build_url($operation), 
        'UTF-8',
        $params, 
        $headers,
    );

    warn p $tx->res->json('error');

    croak $tx->res->json('error') if $tx->res->json('error');
    return $tx->res->json;
}

sub _build_url {
    my $self = shift;
    my $operation = shift;

    return "https://" . $self->access_code . ":@" . $self->endpoint . $operation;
}

1;
