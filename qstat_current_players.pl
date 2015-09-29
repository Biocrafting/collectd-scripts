#!/usr/bin/perl
use strict;
use warnings;

my $Interval = defined ($ENV{'COLLECTD_INTERVAL'}) ? (0 + $ENV{'COLLECTD_INTERVAL'}) : 120;
my $Hostname = defined ($ENV{'COLLECTD_HOSTNAME'}) ? $ENV{'COLLECTD_HOSTNAME'} : 'localhost';
$| = 1;

#Set this to your qstat path
my $qstat_exe='/usr/bin/qstat';
if (-e $qstat_exe) {
	while(42) {
		#Edit the following line to add your gameserver
		query_host("gametype", "IP", "PORT");
		sleep(${Interval});
	}
}else{
	print "Please install qstat or modify the path to the qstat binary.";
}
#subroutine for gathering player informations
sub query_host {
	my $gametype=$_[0];
	my $ip=$_[1];
	my $port=$_[2];

	my $raw= `${qstat_exe} -raw ';' -nh -${gametype} ${ip}:${port}`;
	my @result = split /;/, $raw;
	if($result[2] !~ /DOWN/)

	{
		my($host, $max_players, $players) = @result[1,4,5];
		my $time = time;
		print "PUTVAL ${Hostname}/${gametype}_${ip}_${port}/gauge-players interval=${Interval} ${time}:${players}\n";
		print "PUTVAL ${Hostname}/${gametype}_${ip}_${port}/gauge-max_players interval=${Interval} ${time}:${max_players}\n";
	}
}
