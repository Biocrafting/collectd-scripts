#!/usr/bin/perl

$Interval = defined ($ENV{'COLLECTD_INTERVAL'}) ? (0 + $ENV{'COLLECTD_INTERVAL'}) : 120;
$Hostname = defined ($ENV{'COLLECTD_HOSTNAME'}) ? $ENV{'COLLECTD_HOSTNAME'} : 'localhost';
$| = 1;
while(42) {
	$qstat_exe='/usr/bin/qstat';

	query_host("a2s", "84.200.19.40", "27015");
	query_host("a2s", "84.200.19.40", "27016");
	query_host("a2s", "84.200.19.40", "27017");
	sleep(${Interval});
}


sub query_host {
	$gametype=$_[0];
	$ip=$_[1];
	$port=$_[2];

	$raw= `${qstat_exe} -raw ';' -nh -${gametype} ${ip}:${port}`;
	@result = split /;/, $raw;
	if($result[2] !~ /DOWN/)

	{
		($host, $max_players, $players) = @result[1,4,5];
		$time = time;
		print "PUTVAL ${Hostname}/${gametype}_${ip}_${port}/gauge-players interval=${Interval} ${time}:${players}\n";
		print "PUTVAL ${Hostname}/${gametype}_${ip}_${port}/gauge-max_players interval=${Interval} ${time}:${max_players}\n";
	}
}
