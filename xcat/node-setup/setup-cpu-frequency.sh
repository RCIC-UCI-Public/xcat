#!/bin/bash
##########################################################################
#### J. Farran
#### Set CPU to run at maximum speed always.

printf "\n CPUs Before:\n "
grep -E '^cpu MHz' /proc/cpuinfo| sort | uniq

/sbin/service    cpuspeed stop  >& /dev/null
/sbin/chkconfig  cpuspeed off   >& /dev/null

/bin/cp /data/node-setup/node-files/etc/init.d/cpu-performance /etc/init.d

/sbin/chkconfig cpu-performance on
/sbin/service cpu-performance start

echo -n " CPUs After: "
grep -E '^cpu MHz' /proc/cpuinfo| sort | uniq

