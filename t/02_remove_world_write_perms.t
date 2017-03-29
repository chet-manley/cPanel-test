#!/usr/bin/env perl
use v5.8.9;
use strict;
use warnings;

use Test::More tests => 4;
use Utils;

my $empty_return = {
  'fail' => {},
  'success' => 0
};
my $utils = Utils->new();

ok( ! defined $utils->remove_world_write_perms(), 'no input, no stored files' );
ok( ! defined $utils->remove_world_write_perms({}), 'empty hash, no stored files' );
is_deeply(
  $utils->remove_world_write_perms({'/var/tmp/does/not/exist' => 1}),
  $empty_return,
  '/var/tmp/does/not/exist'
);
is_deeply(
  $utils->remove_world_write_perms({'/bin/true' => 1}),
  $empty_return,
  '/bin/true'
);
