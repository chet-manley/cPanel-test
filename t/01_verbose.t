#!/usr/bin/env perl
use v5.8.9;
use strict;
use warnings;

use Test::More tests => 56;
use Utils;

my $utils;

ok( $utils = Utils->new(),                   'verbose off' );
ok( $utils->verbose()                  == 0, 'no input' );
ok( $utils->verbose(0)                 == 0, 'zero' );
ok( $utils->verbose(0, 0)              == 0, 'zero, zero' );
ok( $utils->verbose(0, 1)              == 0, 'zero, one' );
ok( $utils->verbose(0, undef)          == 0, 'zero, undef' );
ok( $utils->verbose(0, '')             == 0, 'zero, empty string' );
ok( $utils->verbose(0, 'true')         == 0, 'zero, string' );
ok( $utils->verbose(1)                 == 0, 'one' );
ok( $utils->verbose(1, 0)              == 0, 'one, zero' );
ok( $utils->verbose(1, 1)              == 0, 'one, one' );
ok( $utils->verbose(1, undef)          == 0, 'one, undef' );
ok( $utils->verbose(1, '')             == 0, 'one, empty string' );
ok( $utils->verbose(1, 'true')         == 0, 'one, string' );
ok( $utils->verbose(undef)             == 0, 'undef' );
ok( $utils->verbose(undef, 0)          == 0, 'undef, zero' );
ok( $utils->verbose(undef, 1)          == 0, 'undef, one' );
ok( $utils->verbose(undef, undef)      == 0, 'undef, undef' );
ok( $utils->verbose(undef, '')         == 0, 'undef, empty string' );
ok( $utils->verbose(undef, 'true')     == 0, 'undef, string' );
ok( $utils->verbose('')                == 0, 'empty string' );
ok( $utils->verbose('', 0)             == 0, 'empty string, zero' );
ok( $utils->verbose('', 1)             == 0, 'empty string, one' );
ok( $utils->verbose('', undef)         == 0, 'empty string, undef' );
ok( $utils->verbose('', '')            == 0, 'empty string, empty string' );
ok( $utils->verbose('', 'true')        == 0, 'empty string, string' );
ok( $utils->verbose('message')         == 0, 'string' );
ok( $utils->verbose('message', 0)      == 0, 'string, zero' );
ok( $utils->verbose('message', 1)      == 0, 'string, one' );
ok( $utils->verbose('message', undef)  == 0, 'string, undef' );
ok( $utils->verbose('message', '')     == 0, 'string, empty string' );
ok( $utils->verbose('message', 'true') == 0, 'string, string' );

# new object, verbose on
ok( $utils = Utils->new({verbose => 1}), 'verbose on' );

# commented out tests that break prove
# If function sends output to STDOUT without a newline,
# prove cannot parse outcome, even if test passes.
# eg: messageok - string # cannot be caught by prove
ok( $utils->verbose()                  == 0, 'no input' );
ok( $utils->verbose(0)                 == 0, 'zero' );
ok( $utils->verbose(0, 0)              == 0, 'zero, zero' );
ok( $utils->verbose(0, 1)              == 0, 'zero, one' );
ok( $utils->verbose(0, undef)          == 0, 'zero, undef' );
ok( $utils->verbose(0, '')             == 0, 'zero, empty string' );
ok( $utils->verbose(0, 'true')         == 0, 'zero, string' );
#ok( $utils->verbose(1)                 == 1, 'one' );
#ok( $utils->verbose(1, 0)              == 1, 'one, zero' );
ok( $utils->verbose(1, 1)              == 1, 'one, one' );
#ok( $utils->verbose(1, undef)          == 1, 'one, undef' );
#ok( $utils->verbose(1, '')             == 1, 'one, empty string' );
ok( $utils->verbose(1, 'true')         == 1, 'one, string' );
ok( $utils->verbose(undef)             == 0, 'undef' );
ok( $utils->verbose(undef, 0)          == 0, 'undef, zero' );
ok( $utils->verbose(undef, 1)          == 0, 'undef, one' );
ok( $utils->verbose(undef, undef)      == 0, 'undef, undef' );
ok( $utils->verbose(undef, '')         == 0, 'undef, empty string' );
ok( $utils->verbose(undef, 'true')     == 0, 'undef, string' );
ok( $utils->verbose('')                == 0, 'empty string' );
ok( $utils->verbose('', 0)             == 0, 'empty string, zero' );
ok( $utils->verbose('', 1)             == 0, 'empty string, one' );
ok( $utils->verbose('', undef)         == 0, 'empty string, undef' );
ok( $utils->verbose('', '')            == 0, 'empty string, empty string' );
ok( $utils->verbose('', 'true')        == 0, 'empty string, string' );
#ok( $utils->verbose('message')         == 1, 'string' );
#ok( $utils->verbose('message', 0)      == 1, 'string, zero' );
ok( $utils->verbose('message', 1)      == 1, 'string, one' );
#ok( $utils->verbose('message', undef)  == 1, 'string, undef' );
#ok( $utils->verbose('message', '')     == 1, 'string, empty string' );
ok( $utils->verbose('message', 'true') == 1, 'string, string' );
