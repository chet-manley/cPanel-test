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
    # perl 5.8 without logical defined-or
    if ( ! $opt ) { $opt = {'verbose' => 0}; }

    # create class object
    my $self = {
      'options' => $opt
    };

    return bless $self, $class;
  }

  ## "private" methods ##

  # requires: n/a
  #  returns: success as (boolean)
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
  #  returns: $world_writable_files (hash ref) or undef
  sub find_world_writable_files {
    my ($self, $dirs) = @_;
    my (@directories) = ();

    # directory array ref not passed or empty
    if ( ! ($dirs && @$dirs) ) { return undef; }

    # remove non-directory elements
    @directories = grep { -d $_ } @$dirs;
    # no good directories left
    if ( ! @directories ) { return undef; }

    find(\&_save_world_writable, @directories);

    return $world_writable_files;
  }

  # requires: n/a
  # optional: $files (hash ref) files to modify
  #  returns: $results (hash ref)
  #           $results->{'success'} number of successes
  #           $results->{'fail'} failed files with errors
  #           or undef
  sub remove_world_write_perms {
    my ($self, $files) = @_;
    my ($file, $perms, $results) = ();

    # file hash ref not passed or empty, use stored file hash ref
    if ( ! ($files && scalar keys %$files) ) {
      # stored hash ref is not empty
      if ( scalar keys %$world_writable_files ) {
        $files = $world_writable_files;
      } else {
        # there are no files
        return undef;
      }
    }

    # prepare hash
    $results = {
      'fail' => {},
      'success' => 0
    };

    for $file ( keys %$files ) {
      # skip non-files
      if ( ! -f $file ) { next; }

      # get file stats again, in case mode has changed
      my $filestats = stat $file;

      # only work on files with o+w perms
      if ( ! ($filestats->mode() & S_IWOTH) ) { next; }

      # get full perms, including "special" bit
      $perms = $filestats->mode() & 07777;

      # apply o-w perms, fail silently
      $results->{'success'} += chmod $perms ^ S_IWOTH, $file
        or $results->{'fail'}->{$file} = $!;
    }

    return $results;
  }

  # requires: $msg (string) message to display, not empty
  # optional: $newline (boolean) print a newline
  #  returns: success as (boolean)
  sub verbose {
    my ($self, $msg, $newline) = @_;

    # missing message or verbose mode not enabled
    if ( ! ( $msg && $self->{'options'}->{'verbose'} ) ) {
      return 0;
    }

    # display provided message
    printf '%s%s', $msg, $newline ? "\n" : '';

    return 1;
  }
}
'false';
