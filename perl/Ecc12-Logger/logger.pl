#!/usr/bin/perl
use strict;
use warnings;

package Ecc12::Logger;
use 5.006;
use strict;
use warnings;

our $VERSION = '1.000';

=head1 NAME

logger.pl (Ecc12::Logger)

=head1 VERSION

1.000

=head1 SYNOPSIS

    ./logger.pl [-dhisVv] [-f file] [-n server] [-P port] [-p pri] [-t tag] [-u socket] [message]
    
=head1 DESCRIPTION

Pure-perl implemenation of the Unix C<logger> binary using L<Sys::Syslog>.  The
reference implemntation is found on Linux / Debian 6.0 (Squeeze).

This pure-perl implementation does not suffer from the same line-length
limitations as the Debian binary.

Options:

=over 4

=item B<-d, --udp>

Use datagram (UDP) instead of the default stream connection (TCP).

=item B<-i, --id>

Log the process ID of the logger process with each line.

=item B<-f, --file file>

Log the contents of the specified file.  This option cannot be combined with a
command-line message.

=item B<-h, --help>

Display a help text and exit.

=item B<-n, --server server>

Write to the specified remote syslog server using UDP instead of to the builtin
syslog routines.

=item B<-P, --port port> [unimplemented -- requires L<Sys::Syslog>, 0.28]

Use the specified UDP port.  The default port number is 514.

=item B<-p, --priority priority>

Enter the message into the log with the specified priority.  The priority may
be specified as a facility.level pair.  For example, -p
local3.info logs the message as informational in the local3 facility.  The
default is user.notice.

Unlike the reference implementation, priorities cannot be specified
numerically.

=item B<-s, --stderr>

Output the message to standard error as well as to the system log.

=item B<-t, --tag tag>

Mark every line to be logged with the specified tag.

=item B<-u, --socket socket>

Write to the specified socket instead of to the builtin syslog routines.

=item B<-V, --version>

Display version information and exit.

=item B<-v, --verbose>

Output additional diagnistic messages to stderr

=item B<-->

End the argument list. This is to allow the message to start with a hyphen (-).

=item B<message>

Write the message to log; if not specified, and the -f flag is not provided,
standard input is logged.

=back

The logger utility exits 0 on success, and >0 if an error occurs.

Valid facility names are: auth, authpriv (for security information of a
sensitive nature), cron, daemon, ftp, kern (can't be generated from user
process), lpr, mail, news, security (deprecated synonym for auth), syslog,
user, uucp, and local0 to local7, inclusive.

Valid level names are: alert, crit, debug, emerg, err, error (deprecated
synonym for err), info, notice, panic (deprecated synonym for emerg), warning,
warn (depre- cated synonym for warning).  For the priority order and intended
purposes of these levels, see syslog(3).

=head1 REQUIRES

=over 4

=item L<Sys::Syslog>, 0.28

=item L<Getopt::Long>

=item L<Pod::Usage>

=back

=head1 EXPORT

None by default.

=cut

############################################################

=head1 SUBROUTINES

=head2 B<< $self->new >>()

Create a Logger object with default $self->{args}

=cut

sub new {
  my $package = shift(@_);
  my $self = {
    args => {
      udp      => undef,
      id       => undef,
      file     => undef,
      server   => undef,
      port     => undef,
      priority => "user.notice",
      stderr   => undef,
      tag      => "logger",
      socket   => undef,
      verbose  => undef,
      help     => undef,
      version  => undef,
      argv     => undef,
    },
  };

  return(bless($self, $package));
}

=head2 B<run>()

Run the logger with the behavior specified by $self->{args}

=cut

sub run {
  my $self = shift(@_);

  die "-P unimplemented\n" if $self->{args}->{port};

  use Sys::Syslog qw( :DEFAULT setlogsock );

  my $type = ['native', 'unix', 'pipe', 'stream', 'console'];
  $type = ['unix', 'pipe', 'stream'] if $self->{args}->{socket};
  $type = 'tcp' if $self->{args}->{server};
  $type = 'udp' if $self->{args}->{server} && $self->{args}->{udp};
  my $path = undef;
  $path = $self->{args}->{socket} if $self->{args}->{socket};
  $path = $self->{args}->{server} if $self->{args}->{server};
  setlogsock $type, $path;

  my ($facility, $level) = split /\./, $self->{args}->{priority};
  $facility && $level or die "invalid priority\n";
  my @opts = ();
  push @opts, "perror" if $self->{args}->{stderr};
  push @opts, "pid" if $self->{args}->{id};
  openlog $self->{args}->{tag}, join(",", @opts), $facility;

  if($self->{args}->{file}) {
    die "file unreadable\n" unless -r $self->{args}->{file};
    open READF, $self->{args}->{file} or die "unable to open file\n";
    syslog $level, $_ while(<READF>);
    close READF;
  } elsif($self->{args}->{argv}) {
    syslog $level, join(" ", @{ $self->{args}->{argv} });
  } else {
    syslog $level, $_ while(<STDIN>);
  }

  closelog
}

############################################################

=head1 MAIN SUBROUTINES

=head2 B<main_version>()

Print version information found in the documentation.

-V will print version information

=head2 B<main_help>()

Print usage information found in the documentation.

-h will print basic usage

-hv will load the man page

=head2 B<main>()

Extracts commandline arguments and initializes the application and
$self->{args}.  Runs the application.

-vvv will dump the args to stderr.

=cut

sub main_version {
  use Pod::Usage;
  print pod2usage(-verbose=>99, -sections=>[qw( NAME VERSION AUTHOR COPYRIGHT LICENSE)]);
  exit;
}

sub main_help {
  use Pod::Usage;
  print $_[0]?pod2usage(-verbose=>99, -sections=>[qw( SYNOPSIS DESCRIPTION )]):pod2usage;
  exit;
}

sub main {
  use Getopt::Long;
  Getopt::Long::Configure "bundling";
  my $app = Ecc12::Logger->new;
  GetOptions($app->{args},
    "udp|d",
    "id|i",
    "file|f=s",
    "server|n=s",
    "port|P=i",
    "priority|p=s",
    "stderr|s",
    "tag|t=s",
    "socket|u=s",
    "verbose|v+",
    "version|V",
    "help|h",
  );
  @{ $app->{args}->{argv} } = @ARGV if $#ARGV >= 0;
  if($app->{args}->{verbose} && $app->{args}->{verbose} >= 3) {
    print map { sprintf("*%s: %s\n", $_, $app->{args}->{$_}||"") } keys(%{$app->{args}});
  }
  main_help $app->{args}->{verbose} if $app->{args}->{help};
  main_version if $app->{args}->{version};
  $app->run;
}
main unless caller;

=head1 META

This module is just a commandline interface to L<Sys::Syslog> that mimics
C<logger>.  90% of this module is boilerplate, documentation, and setting
commandline arguments.  L<Sys::Syslog> does all that heavy lifting.

If L<Sys::Syslog>, 0.28 becomes availables on the target systems, then -P can
be implemented in $self->run to use the options hash instead of the ordered
arguments (which provides alternate port number functionality).

=head1 AUTHOR

Cameron King cameron@ecc12.com

=head1 COPYRIGHT

Copyright 2012 Cameron C. King. All rights reserved.

=head1 LICENSE

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

