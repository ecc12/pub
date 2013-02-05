#!/usr/bin/perl
package Ecc12::EcCron;

use 5.012004;
use strict;
use warnings;
our $DEBUG=1;

our $VERSION = '1.00';

=head1 NAME

Ecc12::EcCron - Configurable cron daemon

=head1 SYNOPSIS

    ./EcCron.pm

=head1 DESCRIPTION

Configurable cron daemon that can run from a user's home directory.

Blah blah blah.

=head2 EXPORT

None by default.

=head1 CONFIG

The config file is a YAML file with the following format:

     pid: /var/run/eccron.pid

     crons:
         # Log date on a complicated schedule
         - on : 1
           yr : 2012
	   mo : 1 3 5 7 9 11
	   dy : 1 15
	   h  : 0 4 8 12 16 22
	   m  : 1 15 30 45
	   run: /bin/date
	   log: /home/cameron/var/log/cron/date.log

	 # DISABLED
	 # Log date every minute
	 - on : 0
	   run: /bin/date
	   log: /home/cameron/var/log/cron/everyminute.log

=cut



sub new {
  my $package = shift(@_);
  return(bless({}, $package));
}

sub configfile {
  unless($#_==1) { warn("configfile: invalid args"); return; }
  my ($self, $cfgf) = @_;
  unless(-e $cfgf) { warn("configfile: file not found"); return; }
  unless(-r $cfgf) { warn("configfile: file not readable"); return; }

  my $cfgs = '';
  open(CFG, "<$cfgf");
  $cfgs .= $_ for(<CFG>);
  close(CFG);

  return($self->config($cfgs));
}

sub config {
  unless($#_==1) { warn("config: invalid args"); return; }
  my ($self, $cfgs) = @_;
  require YAML::Loader;
  my $loader = YAML::Loader->new();
  my $config = $loader->load($cfgs);
  for(qw( pid crons )) {
    unless(exists($config->{$_})) {
      warn("config: missing required option '$_'"); 
      return;
    }
  }
  unless($#{ $config->{'crons'} } >= 0) {
    warn("config: no crons defined");
    return;
  }
  my $enabled = 0;
  for(0 .. $#{ $config->{'crons'} }) {
    $enabled = 1 if($config->{'crons'}->[$_]->{'on'});
  }
  unless($enabled) { warn("config: no crons enabled"); return; }
  $self->{'config'} = $config;
}

sub run {
  
}




main() unless caller();
sub main {
  my($app) = Ecc12::EcCron->new();
  $app->configfile('/etc/eccron.cfg');
  $app->run();
}
  

=head1 AUTHOR

Cameron King E<cking@ecc12.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2011 Cameron C. King. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

1. Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY CAMERON C. KING ''AS IS'' AND ANY EXPRESS OR
IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL CAMERON C. KING OR CONTRIBUTORS BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
SUCH DAMAGE.

=cut
1;
