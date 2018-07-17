#!/bin/bash
### J. Farran
### Setup the cronny on the compute nodes.
### 5/2018

# We need to copy some check scritps on the node itself in the event the
# node does not have outside connetion like to /data FS in the future:

# List of nodes to IGNORE and exclude from cron being udpated:
IGNORE_LIST="/data/system-files/ignore-cron-updates"     

HOST=`/bin/hostname`

if [[ "$HOST"  =~ "compute-" ]];then
    CHECK=`cat $IGNORE_LIST | sed 's/#.*//' | sed '/^\s*$/d' | grep $HOST`
    if [ ! -z "$CHECK" ];then
	printf "\nThis compute node [ $HOST ] is excluded from having cron being updated.\n"
	printf "Node is listed in exclusion file: $IGNORE_LIST\nExiting...\n\n"
	exit
    fi
else
    printf "\nError: This is NOT a compute node.\nCron will NOT be updated on [ $HOST ]\nExiting...\n\n"
    exit
fi
printf "\nUpdating root cron on this node [ $HOST ]\n\n"

/bin/cp -f /data/xcat/node-setup/node-files/root/node-check-services.sh   /root
/bin/cp -f /data/xcat/node-setup/node-files/root/node-check-mounts.sh     /root

HPC_CRON=/data/xcat/node-setup/node-files/node-crond
DIFF=`/usr/bin/diff $HPC_CRON  /var/spool/cron/root`
if [ ! -z "$DIFF" ] || [ ! -s /var/spool/cron/root ];then
    echo " "
    echo "Cronny has changed on mothership HPC."
    echo "$DIFF"
    echo "-------------------------------------"
    echo "Updating cronny on [ $HOST ]."
    /bin/cp -f $HPC_CRON  /var/spool/cron/root
    /sbin/service crond restart
    echo " "
    echo "Crontab for [$HOST]:"
    /usr/bin/crontab -l
    echo " "
fi
