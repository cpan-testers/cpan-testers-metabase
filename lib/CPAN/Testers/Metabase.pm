# Copyright (c) 2010 by David Golden. All rights reserved.
# Licensed under Apache License, Version 2.0 (the "License").
# You may not use this file except in compliance with the License.
# A copy of the License was distributed with this file or you may obtain a 
# copy of the License from http://www.apache.org/licenses/LICENSE-2.0

package CPAN::Testers::Metabase;
use strict;
use warnings;

our $VERSION = '0.001';
$VERSION = eval $VERSION; ## no critic

use JSON ();
use Metabase::Gateway ();

#--------------------------------------------------------------------------#

use namespace::autoclean;
use Moose::Role;
use MooseX::Params::Validate;

requires  'public_librarian';
requires  'public_librarian_config';

requires  'private_librarian';
requires  'private_librarian_config';

has 'fact_classes' => (
  is => 'ro',
  isa => 'ArrayRef', 
  default => sub { ['CPAN::Testers::Report'] }, 
);

has 'disable_security' => (
  is => 'ro',
  isa => 'Bool', 
  default => 0
);

has 'allow_registration' => (
  is => 'ro',
  isa => 'Bool',
  default => 1,
);

has 'gateway' => (
  is => 'ro',
  isa => 'Metabase::Gateway',
  lazy => 1,
  _builder => '_build_gateway',
);

sub _build_gateway {
  my $self = shift;
  return Metabase::Gateway->new(
    public_librarian    => $self->public_librarian,
    private_librarian   => $self->private_librarian,
    fact_classes        => $self->fact_classes,
    disable_security    => $self->disable_security,
    allow_registration  => $self->allow_registration,
  );
}

#--------------------------------------------------------------------------#
# methods
#--------------------------------------------------------------------------# 

sub web_config {
  my $self = shift;
  my $config = {
    'Model::Metabase' => {
      gateway   => {
        CLASS => 'Metabase::Gateway',
        autocreate_profile => $self->autocreate_profile,
        disable_security => $self->disable_security,  
        public_librarian => {
          CLASS => 'Metabase::Librarian',
          %{ $self->public_librarian_config },
        },
        private_librarian => {
          CLASS => 'Metabase::Librarian',
          %{ $self->private_librarian_config },
        },
      },
      fact_classes => [
        'Metabase::User::Profile',
        @{ $self->fact_classes },
      ],
    }
  };

  return JSON->new->encode($config);

}

__PACKAGE__->meta->make_immutable;

1;

__END__

=begin wikidoc

= NAME

CPAN::Testers::Metabase - Instantiate a Metabase backend for CPAN Testers 

= VERSION

This documentation describes version %%VERSION%%.

= SYNOPSIS

    use CPAN::Testers::Metabase::AWS;

    my $mb = CPAN::Testers::Metabase::AWS->new( %aws_args );

    my $librarian = $mb->public_librarian;
    my $gateway = $mb->gateway;

    print $mb->web_config;

= DESCRIPTION


= USAGE


= BUGS

Please report any bugs or feature requests using the CPAN Request Tracker  
web interface at [http://rt.cpan.org/Dist/Display.html?Queue=CPAN-Testers-Metabase]

When submitting a bug or request, please include a test-file or a patch to an
existing test-file that illustrates the bug or desired feature.

= SEE ALSO


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

