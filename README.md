# collectd-scripts
Various collectd exec scripts for gathering informations


# Usage
To use these scripts, add following code to the configuration of your collectd instance

```
LoadPlugin exec

<Plugin exec>
  Exec "user" "/path/to/script.pl"
</Plugin>
```
