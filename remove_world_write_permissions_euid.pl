#!/usr/bin/env perl

use v5.8.9;
use strict;
use warnings;

use Cwd qw(abs_path);
use File::Basename qw(dirname);
use Getopt::Long;
use Pod::Usage;

# custom libraries
use lib dirname(abs_path $0) . '/lib';
use Utils;

# initialize variables
my ($exit_code, $options, $utils) = ();

# run the program
run();

# required: $euid (unsigned integer)
#  returns: success as (boolean)
sub change_euid {
  my $euid = shift;

  # set new EUID
  $> = $euid;

  # check for failure
  if ( $! ) {
    $utils->verbose("Set EUID failed: $!", 1);
    return 0;
  }

  return 1;
}

# requires: $results (hash ref)
#  returns: success as (boolean)
sub parse_results {
  my $results = shift;

  # display successes
  if ( $results->{'success'} ) {
    printf "Successfully removed world write permissions from %d files.\n",
      $results->{'success'};
  }

  # display failures
  if ( scalar keys %{ $results->{'fail'} } ) {
    printf "Failed to remove world write permissions from %d files.\n",
      scalar keys %{ $results->{'fail'} };

    # display errors
    while (my ($file, $error) = each %{ $results->{'fail'} }) {
      $utils->verbose("$file : $error", 1);
    }

    # set shell exit code
    if ( $results->{'success'} ) {
      $exit_code = 3;
    } else {
      $exit_code = 4;
    }
  }

  return 1;
}

# requires: n/a
#  returns: 1
sub setup {
  my ($go) = ();

  # initialize shell exit code and options hash
  $exit_code = 0;
  $options = {
    'dirs' => []
  };

  # parse command line options with bundling options
  $go = Getopt::Long::Parser->new(config => ['bundling']);
  $go->getoptions($options,
    'euid|e=i',
    'verbose|v',
    'help|?'
  ) or pod2usage "Try '$0 --help' for more information.";

  # display help and exit
  if ( $options->{'help'} ) { pod2usage 2; }

  # instantiate class objects
  $utils = Utils->new({
    'verbose' => $options->{'verbose'}
  });

  # no arguments passed, display help and exit
  if ( ! @ARGV ) { pod2usage 'At least one directory is required.'; }

  # setuid requested
  if ( defined $options->{'euid'} ) {
    if ( change_euid($options->{'euid'}) ) {
      $utils->verbose( sprintf('Running with requested EUID: %d', $>), 1 );
    } else {
      warn "Could not change EUID. Try running with elevated privileges (got sudo?).\n";
    }
  }

  # test our directories
  foreach ( @ARGV ) {
    if ( ! -d $_ ) {
      $utils->verbose( qq("$_" is not a valid directory.), 1 );
    } else {
      push @{ $options->{'dirs'} }, $_;
    }
  }

  # no valid directories, display help and exit
  if ( ! @{ $options->{'dirs'} } ) {
    pod2usage 'No valid directories were found.';
  }

  return 1;
}

sub run {
  my ($files, $results) = ();

  # set up options, arguments and classes
  setup;

  # display status message (dirs with many files may take awhile)
  $utils->verbose('Searching for world writable files...');

  # find all world writable files in dirs and subdirs
  $files = $utils->find_world_writable_files($options->{'dirs'});

  # display findings
  $utils->verbose(sprintf('Found: %d', scalar keys %$files), 1);

  # exit immediately if no files were found
  if ( ! scalar keys %$files ) { return $exit_code; }

  # display status message
  $utils->verbose('Modifying permissions...');

  # remove offending permissions
  $results = $utils->remove_world_write_perms();

  # display findings
  $utils->verbose('Done.', 1);

  # display final results
  parse_results $results;

  return $exit_code;
}

# exit to shell
exit $exit_code;

__END__

=head1 SYNOPSIS

remove_world_write_permissions_euid.pl <directory> [<directory>] [-e] [-v]

=head1 OPTIONS

  -e, --euid            Set Effective UID
  -v, --verbose         Display verbose output
  -?, --help            This help message

=cut
