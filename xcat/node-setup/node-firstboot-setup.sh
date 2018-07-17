#!/bin/sh
# chkconfig: 2345 99 00
# description: Configures the node with our setup.
# J. Farran December 2011
# I. Toufique November 2017

case "$1" in
    start)
        ### Begin first boot script ###
        cd /
        /usr/bin/wall "Starting First Boot Setup"
        /bin/mkdir /tmp/mnt
        /bin/mount -o ro  10.1.255.239:/data  /tmp/mnt
        /bin/sh -x /tmp/mnt/xcat/node-setup/node-setup.sh >& /root/node-setup.log
        #/bin/umount /tmp/mnt
        mkdir -p /tmp/install
        #mount -o ro 10.1.1.20:/install /tmp/install
        #/tmp/install/hpc/yum-to-install.sh
        /usr/bin/wall "Done with First Boot Setup."
        /sbin/chkconfig node-firstboot-setup.sh off
        ;;
    stop)
        /bin/echo 'nothing to be done.'
        ;;
    status)
        /bin/cat /root/node-first-boot-setup.log
        ;;
    *)
    echo 'Usage: /sbin/service node-firstboot-setup.sh {start|stop|status}'
    exit 1
esac
