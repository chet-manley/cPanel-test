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

# requires:
#  returns: 1
sub display_results {
  my () = ();

  # print final results

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

  # test our directories
  foreach ( @ARGV ) {
    if ( ! -d $_ ) {
      $utils->verbose( qq("$_" is not a valid directory.) );
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
  $utils->verbose(
    sprintf('Found %d files with world write permissions.',
      scalar keys %$files)
  );
  # debug
  foreach (keys %$files) { print "$_\n"; }

  # remove offending permissions
  $results = $utils->remove_world_write_perms();

  return $exit_code;
}

__END__

=head1 SYNOPSIS

remove_world_write_permissions.pl <directory> [<directory>] [-v]

=head1 OPTIONS

  -v, --verbose         Display verbose output
  -?, --help            This help message

=cut
