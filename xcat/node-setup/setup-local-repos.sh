#!/bin/bash
##########################################################################
# J. Farran

if [[ `hostname` == "services-xcat" ]];then
    printf "\n -----> Do NOT run this on XCAT Server!   Exiting.\n\n"
    exit -1
fi

OLDREPOS=/etc/yum.repos.d-old
/bin/mkdir -p $OLDREPOS
/bin/mv -f /etc/yum.repos.d/*  $OLDREPOS  >& /dev/null

/bin/cp -f  /data/xcat/node-setup/node-files/CentOS-7/etc/yum.repos.d/*   /etc/yum.repos.d/

printf "\n ---> Yum Clean-up.\n\n"
/bin/rm -Rf /var/cache/yum/*
yum clean metadata
yum clean all

yum -y install yum-utils >& /dev/null

/usr/sbin/yum-complete-transaction

