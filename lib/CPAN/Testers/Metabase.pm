use strict;
use warnings;
package CPAN::Testers::Metabase;
# ABSTRACT: Instantiate a Metabase backend for CPAN Testers 

1;

__END__

=begin wikidoc

= SYNOPSIS

    use CPAN::Testers::Metabase::AWS;

    my $mb = CPAN::Testers::Metabase::AWS->new( %aws_args );

    my $librarian = $mb->public_librarian;

= DESCRIPTION

The CPAN::Testers::Metabase namespace is intended to span a collection
of subclasses that instantiate specific Metabase backend storage and indexing
capabilities for a CPAN Testers style Metabase.

Each subclass consumes the [Metabase::Gateway] role and can be used by
the [Metabase::Web] application as a data model.

See specific classes for more detail:

* [CPAN::Testers::Metabase::AWS] -- storage and indexing with
Amazon Web Services

* [CPAN::Testers::Metabase::Demo] -- SQLite archive and flat-file
index (for test/demo purposes only)

= BUGS

Please report any bugs or feature requests using the CPAN Request Tracker  
web interface at [http://rt.cpan.org/Dist/Display.html?Queue=CPAN-Testers-Metabase]

When submitting a bug or request, please include a test-file or a patch to an
existing test-file that illustrates the bug or desired feature.

=end wikidoc

=cut

