use strict;
use warnings;
package CPAN::Testers::Metabase::MongoDB;
# ABSTRACT: Metabase backend on MongoDB
# VERSION

use Moose;
use Metabase::Archive::MongoDB 1.000;
use Metabase::Index::MongoDB 1.000;
use Metabase::Librarian 1.000;
use namespace::autoclean;

with 'Metabase::Gateway';

has 'db_prefix' => (
  is        => 'ro',
  isa       => 'Str',
  required  => 1,
);

has 'host' => (
  is        => 'ro',
  isa       => 'Str',
  required  => 1,
);

sub _build_fact_classes { return [qw/CPAN::Testers::Report/] }

sub _build_public_librarian { return $_[0]->__build_librarian("public") }

sub _build_private_librarian { return $_[0]->__build_librarian("private") }

sub __build_librarian {
  my ($self, $subspace) = @_;
  my $db_prefix = $self->db_prefix;

  return Metabase::Librarian->new(
    archive => Metabase::Archive::MongoDB->new(
      db_name => "${db_prefix}_${subspace}",
      host => $self->host,
    ),
    index => Metabase::Index::MongoDB->new(
      db_name => "${db_prefix}_${subspace}",
      host => $self->host,
    ),
  );
}

__PACKAGE__->meta->make_immutable;
1;

__END__

=begin wikidoc

= SYNOPSIS

== Direct usage

  use CPAN::Testers::Metabase::MongoDB;

  my $mb = CPAN::Testers::Metabase::MongoDB->new( 
    db_prefix => "my_metabase",
    host      => "mongodb://localhost:27017",
  );

  $mb->public_librarian->search( %search spec );
  ...

== Metabase::Web config

  ---
  Model::Metabase:
    class: CPAN::Testers::Metabase::MongoDB
      args:
        db_prefix: my_metabase
        host: "mongodb://localhost:27017/"

= DESCRIPTION

This class instantiates a Metabase backend that uses MongoDB for storage and
indexing.

= USAGE

== new

  my $mb = CPAN::Testers::Metabase::MongoDB->new( 
    db_prefix => "my_metabase",
    host      => "mongodb://localhost:27017",
  );

Arguments for {new}:

* {db_prefix} -- required -- a unique namespace for the collections
* {host} -- required -- a MongoDB connection string

== Metabase::Gateway Role

This class does the [Metabase::Gateway] role, including the following
methods:

* {handle_submission}
* {handle_registration}
* {enqueue}

see [Metabase::Gateway] for more.

= SEE ALSO

* [CPAN::Testers::Metabase]
* [Metabase::Gateway]
* [Metabase::Web]
* [Net::Amazon::Config]

=end wikidoc

=cut
