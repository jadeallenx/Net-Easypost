package Net::Easypost::PostOnBuild;

use Moo::Role;

sub BUILD {}
after BUILD => sub {
    my $self = shift;

   my $resp = $self->requester->post(
      $self->operation,
      $self->serialize,
   );
   $self->_set_id( $resp->{id} );
};

=method serialize

Format the defined attributes for a call to the Easypost service.
Takes an arrayref of attributes to serialize. Defaults to the C<fieldnames> attribute.

=cut

sub serialize {
   my ($self, $attrs) = @_;
   $attrs //= $self->fieldnames;

   # want a hashref of e.g., role[field1] => foo from all defined attributes
   return {
      map { $self->role . "[$_]" => $self->$_ }
         grep { defined $self->$_ }
            @$attrs
   };
}

1;
