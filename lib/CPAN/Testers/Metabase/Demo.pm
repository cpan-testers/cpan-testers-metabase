use strict;
use warnings;
package CPAN::Testers::Metabase::Demo;
# ABSTRACT: Demo Metabase backend

use Moose;
use Metabase::Archive::SQLite;
use Metabase::Index::FlatFile;
use Metabase::Librarian;
use Path::Class;
use File::Temp;
use namespace::autoclean;

with 'Metabase::Gateway';

has 'data_directory' => (
  is        => 'ro',
  isa       => 'Str',
  lazy      => 1,
  builder   => '_build_data_directory',
);

# keeps the tempdir alive until process exits
has '_cache' => (
  is        => 'ro',
  isa       => 'HashRef',
  default   => sub { {} },
);

sub _build_data_directory {
  my $self = shift;
  return q{} . ( $self->_cache->{tempdir} = File::Temp->newdir ); # stringify
}

sub _build_fact_classes { return [qw/CPAN::Testers::Report/] }

sub _build_public_librarian { return $_[0]->__build_librarian("public") }

sub _build_private_librarian { return $_[0]->__build_librarian("private") }

sub __build_librarian {
  my ($self, $subspace) = @_;

  my $data_dir = dir( $self->data_directory )->subdir($subspace);
  $data_dir->mkpath or die "coudln't make path to $data_dir";

  my $index = $data_dir->file('index.json');
  $index->touch;

  my $archive = $data_dir->file('archive.sqlite');

  return Metabase::Librarian->new(
    archive => Metabase::Archive::SQLite->new(
      filename => "$archive",
    ),
    index => Metabase::Index::FlatFile->new(
      index_file => "$index",
    ),
  );
}

__PACKAGE__->meta->make_immutable;
1;

__END__

=begin wikidoc

= SYNOPSIS

== Direct usage

  use CPAN::Testers::Metabase::Demo;

  # defaults to directory on /tmp
  my $mb = CPAN::Testers::Metabase::Demo->new;
  
  $mb->public_librarian->search( %search spec );

== Metabase::Web config

  ---
  Model::Metabase:
    class: CPAN::Testers::Metabase::Demo

= DESCRIPTION

This is a demo Metabase backend that uses SQLite and a flat file in
a temporary directory.

= USAGE

== new

  my $mb = CPAN::Testers::Metabase::AWS->new( 
    data_directory => "/tmp/my-metabase"
  );

Arguments for {new}:

* {data_directory} -- optional -- directory path to store data files.  Defaults
to a [File::Temp] temporary directory

= BUGS

Please report any bugs or feature requests using the CPAN Request Tracker  
web interface at [http://rt.cpan.org/Dist/Display.html?Queue=CPAN-Testers-Metabase]

When submitting a bug or request, please include a test-file or a patch to an
existing test-file that illustrates the bug or desired feature.

= SEE ALSO

* [CPAN::Testers::Metabase]
* [Metabase::Gateway]
* [Metabase::Web]

=end wikidoc

=cut
