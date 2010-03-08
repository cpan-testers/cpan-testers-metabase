package CPAN::Testers::Metabase::AWS;
use strict;
use warnings;

our $VERSION = "0.001";
$VERSION = eval $VERSION;

use Moose;
use Metabase::Archive::S3;
use Metabase::Index::SimpleDB;
use Metabase::Librarian;
use Net::Amazon::Config;
use namespace::autoclean;

with 'Metabase::Gateway';

has 'bucket' => (
  is        => 'ro',
  isa       => 'Str',
  required  => 1,
);

has 'namespace' => (
  is        => 'ro',
  isa       => 'Str',
  required  => 1,
);

has 'amazon_config' => (
  is        => 'ro',
  isa       => 'Net::Amazon::Config',
  default   => sub { return Net::Amazon::Config->new },
);

has 'profile_name' => (
  is        => 'ro',
  isa       => 'Str',
  default   => 'cpantesters'
);

has '_profile' => (
  is      => 'ro',
  isa     => 'Net::Amazon::Config::Profile',
  lazy    => 1,
  builder => '_build__profile',
  handles => [ qw/access_key_id secret_access_key/ ],
);

sub _build__profile { 
  my $self = shift;
  return $self->amazon_config->get_profile( $self->profile_name );
}

sub _build_fact_classes { return [qw/CPAN::Testers::Report/] }

sub _build_public_librarian { return $_[0]->__build_librarian("public") }

sub _build_private_librarian { return $_[0]->__build_librarian("private") }

sub __build_librarian {
  my ($self, $subspace) = @_;

  my $namespace   = $self->namespace;
  my $s3_prefix   = "metabase/$namespace/$subspace";
  my $sdb_domain  = "cpantesters.metabase.$namespace.$subspace";

  return Metabase::Librarian->new(
    archive => Metabase::Archive::S3->new(
      access_key_id     => $self->access_key_id,
      secret_access_key => $self->secret_access_key,
      bucket            => $self->bucket,
      prefix            => $s3_prefix,
      compressed        => 1,
    ),
    index => Metabase::Index::SimpleDB->new(
      access_key_id     => $self->access_key_id,
      secret_access_key => $self->secret_access_key,
      domain            => $sdb_domain,
    ),
  );
}

__PACKAGE__->meta->make_immutable;
1;

__END__

=begin wikidoc

= NAME

CPAN::Testers::Metabase::AWS - Metabase backend on Amazon Web Services

= VERSION

This documentation describes version %%VERSION%%.

= SYNOPSIS

== Direct usage

  use CPAN::Testers::Metabase::AWS;

  my $mb = CPAN::Testers::Metabase::AWS->new( 
    bucket    => 'myS3bucket',
    namespace => 'prod' 
  );

  $mb->public_librarian->search( %search spec );
  ...

== Metabase::Web config

  ---
  Model::Metabase:
    class: CPAN::Testers::Metabase::AWS
      args:
        bucket: myS3bucket
        namespace: prod

= DESCRIPTION

(Need to discuss how this uses Net::Amazon::Config)

= USAGE

== new()

  my $mb = CPAN::Testers::Metabase::AWS->new( 
    namespace     => 'prod', 
    profile_name  => 'cpantesters',
  );

Arguments for {new}:

* {bucket} -- required -- the Amazon S3 bucket name to hold both public and private
fact content
* {namespace} -- required -- a short phrase that uniquely identifies this
metabase.  E.g. "dev", "test" or "prod".  It is used to specify
specific locations within the S3 bucket and to uniquely identify an
Amazon SimpleDB domain for indexing.
* {amazon_config} -- optional -- a [Net::Amazon::Config] object containing
Amazon Web Service credentials.  If not provided, one will be created using
the default location for the config file.
* {profile_name} -- optional -- the name of a profile for use with 
Net::Amazon::Config.  If not provided, it defaults to 'cpantesters'.

== access_key_id

Returns the AWS Access Key ID.

== secret_access_key

Returns the AWS Secret Access Key

== Metabase::Gateway Role

This class does the [Metabase::Gateway] role, including the following
methods:

* {handle_submission}
* {handle_registration}
* {enqueue}

see [Metabase::Gateway] for more.

= BUGS

Please report any bugs or feature requests using the CPAN Request Tracker  
web interface at [http://rt.cpan.org/Dist/Display.html?Queue=CPAN-Testers-Metabase]

When submitting a bug or request, please include a test-file or a patch to an
existing test-file that illustrates the bug or desired feature.

= SEE ALSO

* [CPAN::Testers::Metabase]
* [Metabase::Gateway]
* [Metabase::Web]

= AUTHOR

David A. Golden (DAGOLDEN)

= COPYRIGHT AND LICENSE

Copyright (c) 2010 by David A. Golden. All rights reserved.

Licensed under Apache License, Version 2.0 (the "License").
You may not use this file except in compliance with the License.
A copy of the License was distributed with this file or you may obtain a 
copy of the License from http://www.apache.org/licenses/LICENSE-2.0

Files produced as output though the use of this software, shall not be
considered Derivative Works, but shall be considered the original work of the
Licensor.

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

=end wikidoc

=cut
