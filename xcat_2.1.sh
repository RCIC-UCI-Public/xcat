#!/bin/bash
##########################################################################
### I. Toufique, J. Walker
### This script adds or removes machines in xcat
### -------------------------------------------------
#script version 2.1

# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
        source /etc/profile.d/xcat.sh

fi

# first order, exit if not root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi
###############################
# defaults.  Change as needed

_network="10.1.100"
HOST=`hostname`
mode="undef"
NODE=none
FORCE=no
discovery_time=25
GROUP=compute
#group defaults
_OSIMAGE=centos6.9
_INSTALLTYPE=install # install is stateful, netboot is stateless
postscripts="updatekernel,confignics -s,setupntp"
###############################

function print_lines () {
    echo "======================================================"
}

#function countdown_timer () {
#secs=$(($uuid_set_wait_time))
#while [ $secs -gt 0 ]; do
#   echo -ne "Remaining: $secs\033[0K\r"
#   sleep 1
#   : $((secs--))
#done
#}

if [ "$HOST" = services-xcat ]; then
    echo ""
    print_lines
    echo "You are on the xcat master machine.... continuing..."
    print_lines
else
    echo ""
    print_lines
    echo "You are not in the xcat master machine..."
    echo "Exiting script... Bye"
    print_lines
    exit 1
fi

function logger() {

    comm=""
    for var in "$@"
    do
        comm="$comm $var"
    done

    if [ comm == "" ]
    then
        echo "Nothing to log"
    else
        comm=${comm:1}
        echo $comm >> $logfile
        eval $comm
    fi

}

function show_menus() {

   if [[ "$mode" == "undef" ]]; then
      echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
      echo " Usage: /tmp/xcat.sh mode [options]"
      echo " -p|--provision           provision a node"
      echo " -d|--delete              remove a node"
      echo " -r|--reimage             re-image without deleting"
      echo " -c|--clear               clear UUIDs"
      echo " -a|--addgroup            Define a group"
      echo " -k|--rmgroup             Remove a group"
      echo " -l|--listgroup           List groups"
      echo " -h|--help                Show help menu"
   # mode-specific help
   elif [[ "$mode" == "provision" ]]; then
      echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
      echo "Usage: /tmp/xcat.sh -p -n node [-f] [-g group]"
      echo "Other variables are defined in the group"
      echo " -f|--force_install       Force re-making even if node exists"
      echo " -g|--group               which group does the node belong to (default compute)"
      echo " -n|--node                node name"
   elif [[ "$mode" == "delete" ]]; then
      echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
      echo "Usage: /tmp/xcat.sh -d -n node"
      echo " -n|--node                node name"
   elif [[ "$mode" == "reimage" ]]; then
      echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
      echo "Usage: /tmp/xcat.sh -r -n node"
      echo " -n|--node                node name"
   elif [[ "$mode" == "clear" ]]; then
      echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
      echo "Usage: /tmp/xcat.sh -c"
   elif [[ "$mode" == "addgroup" ]]; then
      echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
      echo "Usage: /tmp/xcat.sh -a -g group [options]"
      echo " -os|--osimage            [Default: centos6.9]"
      echo " -t|--installtype         [Default: install]"
      echo " -s|--postscripts         [Default: \"updatekernel\",\"confignics -s\",\"setupntp\""
   elif [[ "$mode" == "rmgroup" ]]; then
      echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
      echo "Usage: /tmp/xcat.sh -k -g group"
      echo "-g|--group                Group name"
   elif [[ "$mode" == "listgroup" ]]; then
      echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
      echo "Usage: /tmp/xcat.sh -l"
   fi

   exit 0
}

# 

# first argument defines the mode of operation
if [[ $# -gt 0 ]]; then
key="$1"
case $key in
   -p|--provision)
   mode="provision"
   ;;
   -d|--delete)
   mode="delete"
   ;;
   -r|-reimage)
   mode="reimage"
   ;;
   -c|-clear)
   mode="clear"
   ;;
   -a|--addgroup)
   mode="addgroup"
   ;;
   -k|--rmgroup)
   mode="rmgroup"
   ;;
   -l|--listgroup)
   mode="listgroup"
   ;;
   *)
   show_menus
   ;;
esac
else
   show_menus
fi
shift # past the first argument

while [[ $# -gt 0 ]]
do
key="$1"
case $key in
   #if another operation mode is also set, or help flag, show the help menu
   -p|--provision)
   show_menus
   ;;
   -d|--delete)
   show_menus
   ;;
   -r|-reimage)
   show_menus
   ;;
   -c|--clear)
   show_menus
   ;;
   -a|--addgroup)
   show_menus
   ;;
   -k|--rmgroup)
   show_menus
   ;;
   -l|--listgroup)
   show_menus
   ;;
   -h|--help)
   show_menus
   ;;

   # otherwise, look for any of the following set
   -f|--force_install)
   FORCE=yes
   ;;
   -g|--group)
   GROUP="$2"
   shift # past argument
   ;;
   -n|--node)
   NODE="$2"
   shift # past argument
   ;;
   -os|--osimage)
   _OSIMAGE="$2"
   shift # past argument
   ;;
   -t|--installtype)
   _INSTALLTYPE="$2"
   shift # past argument
   ;;
   -s|--postscripts)
   postscripts="$2"
   shift # past argument
   ;;
   *)
   echo "unknown option"
   echo "$key is not a known option"
   echo
   echo show_menus
   ;;

#   -c|--clean)
#   PURGE="$2"
#   shift # past argument
#   ;;
#   -u|--undiscover)
#   UNDISCOVER="$2"
#   shift # past argument
#   ;;
#   -mac|--macaddr)
#   MACADDR="$2"
#   shift # past argument
#   ;;
#   -ip|--ipaddr)
#   IPADDR="$2"
#   shift # past argument
#   ;;

esac
shift # past argument or value
done

function find_ip_new() {
nmap_out="/tmp/nmap.out"

if [ -f $nmap_out ]; then
    rm -fr $nmap_out
fi

logger nmap -v -sn -n $_network.150-199 -oG - | awk '/Status: Down/{print $2}' > $nmap_out

#in case we forget to save the broadcast address
#sed -i '/10.1.1.255/d' $nmap_out
_IP=`cat $nmap_out`
for k in $_IP
do
 # echo "IP: $k"
   logger grep -q $k /etc/hosts
   if [ $? -ne 0 ]; then
     echo "$k is not in /etc/hosts and is unused"
     logger export IPPADDR="$k"
     break;
   fi
done
}

#find_ip_new

function purge_node () {
 logger nodepurge $NODE
}

function check_node_exists () {
# We check to see if node exists in Xcat/
# if node exists, and force option is set,
# node is cleared and readded (later)

   logger nodels | grep -q $NODE
   if [ $? -eq 0 ]; then
     echo ""
     print_lines
     echo "Node exists in Xcat..."
     echo "Checking to see if force option was set."
     print_lines
        if [ "$FORCE" == "yes" ]; then
           echo ""
           print_lines
           echo "Force node purge was set, clearing node record..."
           print_lines
           purge_node
           print_lines
        else
           echo ""
           print_lines
           echo "Force option was not set..."
           echo "Manually process the node, then rerun script.  Bye!"
           print_lines
           exit 1;
        fi
   else 
    echo ""
    print_lines
    echo "Node does not exist, process with setup..."
    print_lines
   fi
}

function get_uuid () {
logger _discovery_file=/tmp/discovery.out
nodediscoverls | egrep -v UUID | grep undef > $_discovery_file

count=`wc -l "$_discovery_file"`
echo ""
echo "Printing the undefined UUIDs"
echo "-------------------------------"
nodediscoverls
echo ""
echo ""

if [$count == 0]; then
   echo "no UUIDs found: no new nodes in discovery"
#elif [$count==1]; then
#   _uuid=`cat "$_disovery_file" | awk '{print $1}'`
else
   # read user input for the UUID
   echo "Please enter the correct UUID for $NODE"
   read _uuid
fi

}

function set_uuid () {
# Need to check if the file is 0 bytes
# how fun is that?
n=0
until [ $n -ge 10 ]
do
          get_uuid
          
      if [ -z "$_uuid" ]; then  
             echo ""
             print_lines 
             echo "No UUID discovered, sleeping for $discovery_time secs..."
             logger n=$[$n+1]
             logger sleep $discovery_time
                    if [ $n -eq 10 ]; then
                       echo ""
                       print_lines
                       echo " nodediscover was run for $discovery_time secs. , node did not show up"
                       echo " via manual discovery process"
                       echo " Here are some things to check: "
                       echo " 1. network connection"
                       echo " 2. Power off the node and power it on again"
                       echo " 3. Watch over the console screen of the node for any errors"
                       echo ""
                       echo " Exiting script, bye!"
                       print_lines
                       exit 1
                    fi
      else
            echo ""
            print_lines
            echo "UUID: $_uuid"
            #break
            echo ""
            break
                  
      fi
done
}

function clear_uuids () {

   logger _discovery_file=/tmp/discovery.out
   logger nodediscoverls > $_discovery_file
   while read -r line; do
      logger _node_state=`echo "$line" | awk '{print $2}'`
      logger _node=`echo "$line" | awk '{print $3}'`
      logger _uuid=`echo "$line" | awk '{print $1}'`
      if [[ $_node =~ "undef" && $_node_state =~ "undef" ]]; then
         logger nodediscoverdef -r -u $_uuid
      fi
   done < /tmp/discovery.out

}

function add_group() {
mkdef -f -t group -o $GROUP os=$_OSIMAGE provmethod=$_OSIMAGE-x86_64-$_INSTALLTYPE-compute
IFS=',' read -r -a postscripts <<< "$postscripts"

for post in "${postscripts[@]}"
do
   chdef -t group -o $GROUP -p postscripts="$post"
done

}

function remove_group() {
prefix="    members="
members="$(lsdef -t group -o $GROUP | grep members)"
members=${members#$prefix}
if [ "$members" == "" ]; then
   rmdef -t group -o $GROUP
else
   echo "Nodes detected in group $GROUP"
   echo "$members"
   echo "Remove group $GROUP anyway: y/n"

   # query user for confirmation
   while read -n 1 -r key; do
      #echo "$key"
      if [ "${key,,}" == 'y' ]; then
         rmdef -t group -o $GROUP
         IFS=',' read -r -a nodes <<< "$members"
         for NODE in "${nodes[@]}"
         do
            /tmp/xcat_2.1.sh -d -n $NODE
         done
         break
      elif [ "${key,,}" == "n" ]; then
         echo "Group removal aborted. Exiting..."
         exit 0
      fi
   done
fi
}

function list_group () {

groups=`lsdef -t group | awk '{print $1}'`

for group in $groups
do
   lsdef -t group -o $group
done

}

function provision_node () {
find_ip_new
logger nodeadd $NODE groups=$GROUP hosts.ip="$k"

IPMI_ADDR="10.3"${k#"10.1"}
# set ipmi in the management node /etc/hosts
chdef -t node -o $NODE nicips.ipmi=$IPMI_ADDR nichostnamesuffixes.ipmi=-ipmi
#logger chdef $NODE -p postscripts="confignics -s"
#logger chdef $NODE -p postscripts=setupntp
logger makedns $NODE
logger makehosts
#this is nodediscoverls and nodediscoverdef
set_uuid
logger nodediscoverdef -u "$_uuid" -n $NODE
logger makedhcp $NODE
# read the provmethod from lsdef
prefix="    provmethod="
provout="$(lsdef $NODE | grep provmethod)"
#echo $prefix
#echo $provout
logger nodeset $NODE osimage=${provout#$prefix}
}

logfile=/tmp/xcat_$(date +%Y%m%d%_H%M)_$NODE.log
echo "Command log" > $logfile

if [ "$mode" == "delete" ]; then
echo "Purging node $NODE"
purge_node

elif [ "$mode" == "clear" ]; then
echo "Clearing UUIDs"
clear_uuids

elif [ "$mode" == "addgroup" ]; then
echo "creating group $GROUP"
add_group

elif [ "$mode" == "rmgroup" ]; then
echo "removing group $GROUP"
remove_group

elif [ "$mode" == "listgroup" ]; then
list_group

elif [ "$mode" == "reimage" ]; then
echo "Re-imaging node"
# read the provmethod from lsdef
prefix="    provmethod="
provout=$(lsdef $NODE | grep provmethod)
nodeset $NODE osimage=${provout#$prefix}

#if no nodename is set, catch it before it provisions
elif [[ "$mode" == "provision" && "$NODE" == "none" ]]; then
show_menus

elif [[ "$mode" == "provision" && "$FORCE" == "no" ]]; then

echo "Setting up node "
echo "Checking if the node exists in xcat..."
check_node_exists
provision_node
echo
echo
echo "IPPADDR : $k"
echo
echo

elif [[ "$mode" == "provision" && "$FORCE" == "yes" ]]; then
# check node exist will purge if force option is set
check_node_exists
provision_node
logger makedhcp $NODE
fi
