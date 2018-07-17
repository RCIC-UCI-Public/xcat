#!/bin/bash
##################################################################
#### J. Farran
#### 10/13
#### Setup /etc/init.d
####

/bin/cp -Rf  /data/xcat/node-setup/node-files/etc/init.d/node-first-boot-check-mounts  /etc/init.d

/sbin/chkconfig node-first-boot-check-mounts on
