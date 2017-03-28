#!/usr/bin/env perl
package Utils;

use v5.8.0;
use strict;
use warnings;

use Fcntl qw(:mode);
use File::Find;
use File::stat;

# force stat instead of nlink
$File::Find::dont_use_nlink = 1;

# the module
{
  # constructor
  sub new {
    my ($class, $opt) = @_;

    # default options
    $opt //= {
      debug => 0,
      verbose => 0
    };

    # create class object
    my $self = {
      files => {},
      options => $opt
    };

    return bless $self, $class;
  }

  ## private methods ##

  # requires: $dirs (array ref) directories to search
  #  returns: success as (binary)
  sub _find_files {
    my ($self, $dirs) = @_;

    find(sub {
      # not a file
      if ( ! -f $File::Find::name ) { return 0; }

      # get file stats
      my $filestats = stat($File::Find::name);

      # save files with o+w attr
      if ( $filestats->mode() & S_IWOTH ) {
        $self->{'files'}->{"$File::Find::name"} => $filestats->mode() & S_IRWXO
        return 1;
      }

      return 0;
    }, @$dirs)

    return $args;
  }

  ## public methods ##

  # requires: $args (hash ref) arguments
  #           $args{hostname} or $args{sid} or $args{ip}
  # optional: $args{active} (binary) only search active appliances
  #           $args{basic} (binary) only return basic info
  #           $args{cid} (integer) only search this CID's appliances
  #           $args{property} (string) return defined property
  #  returns: appliance info as (hash ref), single property or undef
  sub get_info {
    my ($self, $args) = @_;
    my ($info, $success) = ();

    # ensure required arguments exist
    return undef
      unless $self->_check_arguments(
        $args,
        ['hostname', 'ip', 'sid'] # any one argument required
      );

    # gather basic info
    $info = $self->{aldb}->get_appliance_info($args);
    if ($info->{'failed'}) {
      $self->{utils}->print_debug({
        type => 'error',
        message => $info->{'failed'}
      });
      return $self->{utils}->print_verbose('Failed to retrieve appliance info.');
    }

    # optional property found
    return $info->{ $args->{'property'} }
      if $args->{'property'} && $info->{ $args->{'property'} };

    # gather advanced details
    $success = $self->_get_advanced_info($info)
      unless $args->{'basic'};
    $self->{utils}->print_verbose('Could not retrieve advanced appliance details.')
      unless $success || $args->{'basic'};

    # optional property found
    return $info->{ $args->{'property'} }
      if $args->{'property'} && $info->{ $args->{'property'} };

    # optional property not found
    return undef if $args->{'property'};

    # hostnames do not match
    $info->{'hostname_mismatch'} = 1
      if $args->{'hostname'} && $args->{'hostname'} ne ($info->{'hostname'} || $info->{'name'});

    # IPs do not match
    $info->{'ip_mismatch'} = 1
      if $args->{'ip'} && $args->{'ip'} ne $info->{'ip'};

    return $info;
  }

  # requires: $args (hash ref) arguments
  #           $args{hostname} or $args{sid} or $args{ip}
  # optional: $args{active} (binary) only search active appliances
  #           $args{basic} (binary) only return basic info
  #           $args{cid} (integer) only search this CID's appliances
  #  returns: appliance as new class object or undef
  sub new_appliance {
    my ($self, $args) = @_;
    my ($appliance) = ();

    # create new class object
    $appliance = ApplianceInfo->new($self->{options});

    # build appliance object
    $appliance->{args} = $args;
    $appliance->{info} = $self->get_info($args);

    return $appliance->{info} ? $appliance : undef;
  }

  # requires: n/a
  #  returns: appliance info as (hash ref) or undef
  sub refresh_info {
    my $self = shift;

    # not an appliance object
    return undef unless $self->{args};

    # replace info hash ref
    $self->{info} = $self->get_info($self->{args});

    return $self->{info};
  }
}
'false';
