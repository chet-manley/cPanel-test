#!/usr/bin/env perl
use v5.8.9;
use strict;
use warnings;

use Scalar::Util qw(blessed);
use Test::More tests => 3;

BEGIN {
  use_ok('Utils');
}

my (@methods, $utils);
@methods = qw(
  find_world_writable_files
  remove_world_write_perms
  verbose
);

ok( blessed ($utils = Utils->new()), 'constructor' );
can_ok( $utils, @methods );
