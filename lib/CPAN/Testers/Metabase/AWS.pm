use strict;
use warnings;
package CPAN::Testers::Metabase::AWS;
# ABSTRACT: Metabase backend on Amazon Web Services
# VERSION

use Moose;
use Metabase::Archive::S3 1.000;
use Metabase::Index::SimpleDB 1.000;
use Metabase::Librarian 1.000;
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

  my $bucket      = $self->bucket;
  my $namespace   = $self->namespace;
  my $s3_prefix   = "metabase/${namespace}/${subspace}/";
  my $sdb_domain  = "${bucket}.metabase.${namespace}.${subspace}";

  return Metabase::Librarian->new(
    archive => Metabase::Archive::S3->new(
      access_key_id     => $self->access_key_id,
      secret_access_key => $self->secret_access_key,
      bucket            => $self->bucket,
      prefix            => $s3_prefix,
      compressed        => 1,
      retry             => 1,
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

This class instantiates a Metabase backend on the S3 and SimpleDB Amazon 
Web Services (AWS).  It uses [Net::Amazon::Config] to provide user credentials
and the [Metabase::Gateway] Role to provide actual functionality.  As such,
it is mostly glue to get the right credentials to setup AWS clients and provide
them with standard resource names.

For example, given the {bucket} "example" and the {namespace} "alpha",
the following resource names would be used:

  Public S3: http://example.s3.amazonaws.com/metabase/alpha/public/*
  Public SDB domain: example.metabase.alpha.public

  Private S3: http://example.s3.amazonaws.com/metabase/alpha/private/*
  Private SDB domain: example.metabase.alpha.private

= USAGE

== new

  my $mb = CPAN::Testers::Metabase::AWS->new( 
    bucket    => 'myS3bucket',
    namespace     => 'prod', 
    profile_name  => 'cpantesters',
  );

Arguments for {new}:

* {bucket} -- required -- the Amazon S3 bucket name to hold both public and private
fact content.  Bucket names must be unique across all of AWS.  The bucket
name is also used as part of the SimpleDB namespace for consistency.
* {namespace} -- required -- a short phrase that uniquely identifies this
metabase.  E.g. "dev", "test" or "prod".  It is used to specify
specific locations within the S3 bucket and to uniquely identify a SimpleDB 
domain for indexing.
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

= SEE ALSO

* [CPAN::Testers::Metabase]
* [Metabase::Gateway]
* [Metabase::Web]
* [Net::Amazon::Config]

=end wikidoc

=cut
