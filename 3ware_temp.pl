#!/usr/bin/perl
use strict;
use warnings;

# This script uses smartctl(8) to read HDD temperatures. The drives are
# attached to a 3ware RAID controller which hddtempd can't handle.
# Please note that only root can read the SMART attributes from harddrives,
# The exec plugin will refuse to run scripts as root, which is why 'sudo' is used here for
# fine-grained root privileges for the user 'smart'. This isn't as straight
# forward as one might hope, but we think that the gained security is worth it.

# The sudo configuration looks something like this:
# -- 8< --
# Cmnd_Alias      SMARTCTL = /usr/sbin/smartctl -d 3ware\,0 -A /dev/twl0, /usr/sbin/smartctl -d 3ware\,1 -A /dev/twl0
# smart   ALL = (root) NOPASSWD: SMARTCTL
# -- >8 --

my $Interval = defined ($ENV{'COLLECTD_INTERVAL'}) ? (0 + $ENV{'COLLECTD_INTERVAL'}) : 120;
my $Hostname = defined ($ENV{'COLLECTD_HOSTNAME'}) ? $ENV{'COLLECTD_HOSTNAME'} : 'localhost';
$| = 1;

#Set this to your smartctl path
my $smartctl_exe='/usr/sbin/smartctl';
if (-e $smartctl_exe) {
	while(42) {
		#Edit the following line to add your hdds
		#         No. Controller  No. HDD
		#smart_temp("twl0",       "0");
		
		smart_temp("twl0", "0");
		sleep(${Interval});
	}
}else{
	print "Please install smartctl or modify the path to the smartctl binary.";
}
#subroutine for gathering informations
sub smart_temp {
	my $controller=$_[0];
	my $hdd=$_[1];
	
	my $raw= `sudo ${smartctl_exe} -d 3ware,${hdd} -A /dev/${controller} | grep Temperature_Celsius`;
	my @result = split /\s+/, $raw;
	if ($result[9] =~ /^[+-]?\d+$/) 
	{
		my $temp = $result[9];
		my $time = time;
		print "PUTVAL ${Hostname}/3ware-${controller}/temperature-p${hdd} interval=${Interval} ${time}:${temp}\n";
	}
}

