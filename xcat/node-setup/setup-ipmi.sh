#!/bin/bash
#### J. Farran
#### Setup IPMI on subnet 10.3.x.x

yum install -y ipmitool ipmiutil

modprobe ipmi_devintf
modprobe ipmi_si
modprobe ipmi_msghandler

HOST=`/bin/hostname`
if [[  "$HOST" =~ "compute-10-" ]] || \
    [[ "$HOST" =~ "compute-11-" ]] || \
    [[ "$HOST" =~ "compute-12-" ]] || \
    [[ "$HOST" =~ "compute-13-" ]];then

    echo "Intel donated node."
    /data/node-setup/setup-ilo.sh # set HP nodes with HP's tool

    LAN=2     # The dondated Intel nodes use Lan 2 instead of 1
else
    LAN=1
fi

IPMI_IP=`hostname -i|awk -F. '{print "10.3."$3"."$4}'`
ipmitool -I open lan set $LAN ipsrc static
ipmitool -I open lan set $LAN ipaddr $IPMI_IP
ipmitool -I open lan set $LAN defgw ipaddr 10.1.1.1 
ipmitool -I open lan set $LAN netmask 255.0.0.0
ipmitool -I open lan set $LAN arp respond on
ipmitool -I open lan set $LAN access on
ipmitool -I open user set password 2 ipmireset
ipmitool -I open lan print $LAN  > /root/ipmi-setup.log

/sbin/chkconfig ipmi on
/sbin/service   ipmi restart

cat /root/ipmi-setup.log
