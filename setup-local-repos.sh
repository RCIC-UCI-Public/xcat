#!/bin/bash
##########################################################################
# J. Farran

if [[ $HOST = hpc-s* ]];then
    echo " "
    echo "-----> Do NOT run this on the head node! Exiting."
    exit -1
fi

FLAG=/root/setup-local-repos-clean.flag
if [ ! -e $FLAG ];then
    /bin/rm -Rf /var/cache/yum/*
    touch $FLAG
fi

OLDREPOS=/etc/yum.repos.d-old
/bin/mkdir -p $OLDREPOS
/bin/mv -f  /etc/yum.repos.d/*  $OLDREPOS  >& /dev/null

CENTOS7=`cat /etc/redhat-release | grep " release 7."`

echo " " 
if [ ! -z "$CENTOS7" ];then
    echo "Setup Local Repos for CentOS-7"
    /bin/cp -f  /tmp/install/hpc/yum.repos.d/*   /etc/yum.repos.d/
else
    echo "Setup Local Repos for CentOS-6"
    #/bin/cp -f  /data/node-setup/node-files/CentOS-6/etc/yum.repos.d/*   /etc/yum.repos.d/
    /bin/cp -f  /tmp/install/hpc/yum.repos.d/*   /etc/yum.repos.d/
fi

echo "---> Yum Clean."
yum clean metadata
yum clean all

yum -y install yum-utils >& /dev/null

/usr/sbin/yum-complete-transaction
