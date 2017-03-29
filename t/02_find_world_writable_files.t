#!/usr/bin/env perl
use v5.8.9;
use strict;
use warnings;

use Test::More tests => 4;
use Utils;

my $utils = Utils->new();

ok( ! defined $utils->find_world_writable_files(), 'no input' );
ok( ! defined $utils->find_world_writable_files([]), 'empty array' );
ok( ! defined $utils->find_world_writable_files(['/var/tmp/does/not/exist/']),
  '/var/tmp/does/not/exist/' );
is( ref $utils->find_world_writable_files(['/var/tmp/']),
  'HASH',
  '/var/tmp/' );
