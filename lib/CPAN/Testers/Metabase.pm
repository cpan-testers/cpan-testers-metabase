use strict;
use warnings;
package CPAN::Testers::Metabase;
# ABSTRACT: Instantiate a Metabase backend for CPAN Testers 
# VERSION

1;

__END__

=head1 SYNOPSIS

  use CPAN::Testers::Metabase::AWS;

  my $mb = CPAN::Testers::Metabase::AWS->new( %aws_args );

  my $librarian = $mb->public_librarian;

=head1 DESCRIPTION

The CPAN::Testers::Metabase namespace is intended to span a collection
of subclasses that instantiate specific Metabase backend storage and indexing
capabilities for a CPAN Testers style Metabase.

Each subclass consumes the L<Metabase::Gateway> role and can be used by
the L<Metabase::Web> application as a data model.

See specific classes for more detail:

=for :list
* [CPAN::Testers::Metabase::AWS] -- storage and indexing with Amazon Web Services
* [CPAN::Testers::Metabase::MongoDB] -- MongoDB storage and indexing
* [CPAN::Testers::Metabase::Demo] -- SQLite archive and flat-file index (for test/demo purposes only)

=cut

