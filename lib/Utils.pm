#!/usr/bin/env perl
package Utils;

use v5.8.9;
use strict;
use warnings;

use Fcntl qw(:mode);
use File::Find;
use File::stat;

# force stat instead of nlink
$File::Find::dont_use_nlink = 1;
# prevent permissions and other File::Find warnings
## Can optionally run calling script with 2>/dev/null,
## but that would supress everything written to STDERR,
## which may not be desirable.
#no warnings "File::Find";

# the module
{
  # "private" variables
  ## Not really private, references can be returned to caller and edited.
  ## Would need to return copies if "better" privacy were preferred.
  my ($world_writable_files) = ({});

  # constructor
  sub new {
    my ($class, $opt) = @_;

    ## does not work in perl 5.8
    # default options
    #$opt //= {
    #  'debug' => 0,
    #  'verbose' => 0
    #};

    # create class object
    my $self = {
      # perl 5.8 without logical defined-or
      'options' => $opt || { 'verbose' => 0 }
    };

    return bless $self, $class;
  }

  ## "private" methods ##

  # requires: n/a
  #  returns: success as (binary)
  sub _save_world_writable {
    # skip non-files
    if ( ! -f $File::Find::name ) { return 0; }

    # get file stats
    my $filestats = stat $File::Find::name;

    # skip files without o+w perms
    if ( ! ($filestats->mode() & S_IWOTH) ) { return 0; }

    # "full file path" => a true value
    $world_writable_files->{"$File::Find::name"} = 1;

    return 1;
  }

  ## "public" methods ##

  # requires: $dirs (array ref) directories to search
  #  returns: $world_writable_files (hash ref) found files
  sub find_world_writable_files {
    my ($self, $dirs) = @_;

    find(\&_save_world_writable, @$dirs);

    return $world_writable_files;
  }

  # requires: n/a
  # optional: $files (hash ref) files to modify
  #  returns: $results (hash ref)
  #           $results->{'success'} number of successes
  #           $results->{'fail'} failed files with errors
  sub remove_world_write_perms {
    my ($self, $files) = @_;
    my ($file, $perms, $results) = ();

    # file hash ref not passed, use stored file hash ref
    if ( ! $files ) { $files = $world_writable_files; }

    # prepare hash
    $results = {
      'fail' => {},
      'success' => 0
    };

    for $file ( keys %$files ) {
      # skip non-files
      if ( ! -f $file ) { continue; }

      # get file stats again, in case mode has changed
      my $filestats = stat $file;

      # only work on files with o+w perms
      if ( ! ($filestats->mode() & S_IWOTH) ) { continue; }

      # get full perms, including "special" bit
      $perms = $filestats->mode() & 07777;

      # apply o-w perms, fail silently
      #$results->{'success'} += chmod $perms ^ S_IWOTH, $file
      #  or $results->{'fail'}->{$file} = $!;
      printf "chmod %#o, $file\n", $perms ^ S_IWOTH;
      $results->{'success'}++
    }

    return $results;
  }

  # requires: $msg (string) message to display, not empty
  #  returns: success as (binary)
  sub verbose {
    my ($self, $msg) = @_;

    # missing message or verbose mode not enabled
    if ( ! ( $msg && $self->{'options'}->{'verbose'} ) ) {
      return 0;
    }

    # display provided message
    print "$msg\n";

    return 1;
  }
}
'false';
