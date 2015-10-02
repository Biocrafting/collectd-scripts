# collectd-scripts
Various collectd exec scripts for gathering informations


# Usage
To use these scripts, add in the script your server ip/port and call it via following code in the configuration of collectd

```
LoadPlugin exec

<Plugin exec>
  Exec "user" "/path/to/script.pl"
</Plugin>
```
