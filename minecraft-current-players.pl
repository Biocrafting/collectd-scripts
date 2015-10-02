#!/usr/bin/perl
use strict;
use warnings;
use IO::Socket;
use Encode        qw(decode);

my $Interval = defined ($ENV{'COLLECTD_INTERVAL'}) ? (0 + $ENV{'COLLECTD_INTERVAL'}) : 120;
my $Hostname = defined ($ENV{'COLLECTD_HOSTNAME'}) ? $ENV{'COLLECTD_HOSTNAME'} : 'localhost';
$| = 1;

while(42) {
	#Edit the following line to add your gameserver
	ping_server("84.200.19.40", "33996");
	sleep(${Interval});
	}


sub ping_server {
    	my($host, $port) = @_;

    	my $socket = IO::Socket->new(
        	Domain   => AF_INET,
        	PeerAddr => $host,
        	PeerPort => $port,
        	Proto    => 'tcp',
    	);

	if($socket) {
		$socket->autoflush(1);
		print $socket "\xFE";
		sysread($socket, my $resp, 256);
		print "Malformed response recieved" unless $resp =~ /^\xFF/;
		substr($resp, 0, 3, '');
		$resp = decode('UCS-2', $resp);
		my @result = split /\x{A7}/, $resp;
		my $players = $result[1];
		my $time = time;
		print "PUTVAL ${Hostname}/minecraft_${host}_${port}/gauge-players interval=${Interval} ${time}:${players}\n";
	} else {
		print "Cant open Socket!";
	}
}
