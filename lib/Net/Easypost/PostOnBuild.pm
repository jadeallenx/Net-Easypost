package Net::Easypost::PostOnBuild;

use Moo::Role;

sub BUILD {}
after 'BUILD' => sub {
    my $self = shift;

   my $resp = $self->requester->post(
      $self->operation,
      $self->serialize,
   );
   $self->_set_id( $resp->{id} );
};

sub serialize {
   my ($self, $attrs) = @_;
   $attrs //= $self->fieldnames;

   # want a hashref of e.g., role[field1] => foo from all defined attributes
   return {
      map  { $self->role . "[$_]" => $self->$_ }
      grep { defined $self->$_ } @$attrs
   };
}

1;

__END__

=pod 

=head1 NAME 

=head1 SYNOPSIS

=head1 METHODS

=over 4 

=item BUILD 

After the Net::Easypost::Resource has been constructure, sends a POST to the Easypost 
service for the type of Net::Easypost::Resource being constructed to get a valid ID

=item serialize

Format the defined attributes for a call to the Easypost service.
Takes an arrayref of attributes to serialize. Defaults to the C<fieldnames> attribute.

=back 

=cut 
