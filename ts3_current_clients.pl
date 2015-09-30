#!/usr/bin/perl -w
use strict;
use Net::Telnet;

my $Interval = defined ($ENV{'COLLECTD_INTERVAL'}) ? (0 + $ENV{'COLLECTD_INTERVAL'}) : 120;
my $Hostname = defined ($ENV{'COLLECTD_HOSTNAME'}) ? $ENV{'COLLECTD_HOSTNAME'} : 'localhost';
$| = 1;

# CONFIG HERE!
my $hostname = "127.0.0.1";  # serveraddress
my $port = 10011;              # queryport (default: 10011)
my @serverids = (1);           # array of virtualserverids (1,2,3,4,...) 

my $username = "";	       # only set if the default queryuser hasn´t enough rights (should work without this)
my $password = "";

while(42) {
	query_host();
	sleep(${Interval});
}

sub query_host {
	my $telnet = new Net::Telnet(Timeout=>5, Errmode=>"return", Prompt=>"/\r/"); 
	if ($telnet->open(Host=>$hostname, Port=>$port)) { 
  		$telnet->waitfor("/Welcome to the TeamSpeak 3 ServerQuery interface/");
  		if($username && $password) {
			$telnet->cmd("login ".$username." ".$password);
			$telnet->waitfor("/error id=0 msg=ok/");
   	 	}
  	foreach my $server (@serverids) {
 	$telnet->cmd("use sid=".$server);
    	$telnet->waitfor("/error id=0 msg=ok/");
	$telnet->cmd("serverinfo");
    	my $clients = 0;
	my $queryclients = 0;
	my $time = time;
	my $voiceclients = 0;
	my $line = $telnet->getline(Timeout=>5);
	if ($line =~ m/virtualserver_clientsonline=(\d+) /) {
		$clients = $1;
	}
	if ($line =~ m/virtualserver_queryclientsonline=(\d+) /) {
		$queryclients = $1;
	}
	$voiceclients = $clients - $queryclients;
    	$telnet->waitfor("/error id=0 msg=ok/");
    	print "PUTVAL ${Hostname}/voice/gauge-ts3_${server} interval=${Interval} ${time}:${voiceclients}\n";
  	}
	$telnet->close;
	}
}
