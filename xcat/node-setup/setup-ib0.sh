#!/bin/bash
#### J. Farran
#### Configure Infinband IPoIB 

if [ ! -e /sbin/lspci ];then
    echo "Cannot continue.  Missing /sbin/lspci.   Exiting..."
    exit
fi

INFINIBAND=''
INFINIBAND=`/sbin/lspci | fgrep "Mellanox"`

if [ ! "$INFINIBAND" ];then
    echo "Node [ `hostname -s` ] does not have Infiniband - Cannot setup ib0."

    if [ -e /etc/sysconfig/network-scripts/ifcfg-ib0 ];then
	echo "---> ifcfg-ib0 exists.   Removing."
	/bin/rm /etc/sysconfig/network-scripts/ifcfg-ib0
    fi
    exit
fi

if [[ `hostname -s` = compute-1-13 ]];then
    echo "This is the interacive node.   Needs to be done manually."
    exit
fi


cat /etc/sysconfig/network-scripts/ifcfg-eth0 | \
    grep -v HWADDR          |\
    grep -v MTU             |\
    grep -v CONNECTED_MODE  |\
    sed -e s/10.1/10.2/     |\
    sed -e s/eth0/ib0/  > /etc/sysconfig/network-scripts/ifcfg-ib0

echo " "
echo "--------------"
echo "NEW ib0 SETUP:"
echo "--------------"
cat /etc/sysconfig/network-scripts/ifcfg-ib0
echo "--------------"
echo " "

/sbin/service network restart
echo " "
echo "--------------------------------------------------------------------"
/sbin/ifconfig ib0
echo "--------------------------------------------------------------------"
echo " "
echo "Now running: /data/node-setup/setup-hosts.sh"
/data/xcat/node-setup/setup-hosts.sh
echo " "
echo "Done."
