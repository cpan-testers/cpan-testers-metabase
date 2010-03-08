# Copyright (c) 2010 by David Golden. All rights reserved.
# Licensed under Apache License, Version 2.0 (the "License").
# You may not use this file except in compliance with the License.
# A copy of the License was distributed with this file or you may obtain a 
# copy of the License from http://www.apache.org/licenses/LICENSE-2.0

use strict;
use lib 'inc';
eval "require Pod::WikiDoc";
my $class = $@ ? "Module::Build" : "Module::Build::WikiDoc";
eval "require $class";
my $build = $class->new( 
    module_name => 'CPAN::Testers::Metabase',
    dist_author => 'David Golden <dagolden@cpan.org>',
    license => 'apache',
    create_readme => 1,
    create_makefile_pl  => 'traditional',
    requires => {
        'perl' => 0, # not specified
        'File::Temp' => 0.20, # 0.14 in perl 5.006002; 0.20 in perl 5.008009; 
        'Metabase::Archive::S3' => 0.003,
        'Metabase::Archive::SQLite' => 0.003,
        'Metabase::Index::FlatFile' => 0.003,
        'Metabase::Index::SimpleDB' => 0.003,
        'Metabase::Librarian' => 0.003,
        'Moose' => 0.93,
        'namespace::autoclean' => 0.09,
        'Net::Amazon::Config' => 0.001,
        'Path::Class' => 0.17,
    },
    build_requires => {
        'File::Find' => 0,
        'File::Spec' => 3.31, # 0.8 in perl 5.00504; 0.86 in perl 5.006002; 3.29 in perl 5.008009; 3.31 is new
        'Test::More' => 0.88, # 0.47 in perl 5.006002; 0.80 in perl 5.008009; 
    },
    meta_add            => { 
        no_index => { 
            directory => [ qw/ examples inc t xt /],
        },
        resources => {
          repository => "http://github.com/dagolden/CPAN-Testers-Metabase/", 
          bugtracker => "http://rt.cpan.org/NoAuth/Bugs.html?Dist=CPAN-Testers-Metabase",
        },
    },
);
$build->create_build_script;

