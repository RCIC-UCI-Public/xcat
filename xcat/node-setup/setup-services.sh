#!/bin/bash
########################################################################
# Daily ( nightly ) things to run on each Compute node.
# J. Farran
# 6/2013
# 5/2018

. /root/.bashrc

/usr/sbin/chkconfig ipmi off         >& /dev/null
/usr/sbin/service   ipmi stop        >& /dev/null

/usr/sbin/chkconfig cpuspeed off     >& /dev/null
/usr/sbin/service   cpuspeed stop    >& /dev/null

/usr/sbin/chkconfig talk on
/usr/sbin/chkconfig ntalk on
/usr/sbin/chkconfig edac on
/usr/sbin/chkconfig crond on
/usr/sbin/chkconfig ipmi on
