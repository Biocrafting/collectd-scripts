#!/usr/bin/perl
use strict;
use warnings;
use IO::Socket;

my $Interval = defined ($ENV{'COLLECTD_INTERVAL'}) ? (0 + $ENV{'COLLECTD_INTERVAL'}) : 120;
my $Hostname = defined ($ENV{'COLLECTD_HOSTNAME'}) ? $ENV{'COLLECTD_HOSTNAME'} : 'localhost';
$| = 1;

# CONFIG HERE!
my $mpd_host = "localhost";
my $mpd_port = "6600";
while(42) {
	mpd_stats();
	sleep(${Interval});
	}
sub mpd_stats {
	my $ans = "";
	my $songs = 0;
	my $albums = 0;
	my $time = time;
	my $socket = new IO::Socket::INET(PeerAddr => $mpd_host,
					PeerPort => $mpd_port,
					Proto => "tcp",
					timeout => 5);
	printf "Could not create socket: $!\n" unless $socket;
	if ( not $socket->getline() =~ /^OK MPD*/ ) {
		print"Could not connect: $!\n";
    	} else {
		print $socket "stats\n";
		while ( not $ans =~ /^(OK|ACK)/ ) {
			$ans = <$socket>;
			if ( $ans =~ s/albums: //) {
				$albums = $ans;
			}
			if ( $ans =~ s/songs: //) {
				$songs = $ans;
			}
		}
		close($socket);
		print "PUTVAL ${Hostname}/mpd/gauge-albums interval=${Interval} ${time}:${albums}";
		print "PUTVAL ${Hostname}/mpd/gauge-songs interval=${Interval} ${time}:${songs}";
	}
}
