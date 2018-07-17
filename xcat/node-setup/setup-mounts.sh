#!/bin/bash
### J. Farran
### Setup the various mounts depending if the node has
### the Mellaonox Infiniband hardware or not.
###
### Note:  This script can be re-ran without issue.
### Note2: Only runs on compute nodes.

HOST=`hostname -s`

if [[ "$HOST"   =~ "compute-"      ]] || \
    [[ "$HOST"  =~ "hpc-login-"    ]] || \
    [[ "$HOST"  =~ "dfs-"          ]] || \
    [[ "$HOST"  =~ "dfm-"          ]] || \
    [[ "$HOST"  =~ "hpc-lightpath" ]] || \
    [[ "$HOST"  =~ "services"      ]] || \
    [[ "$HOST"  =~ "nas-"          ]]; then
    echo "Working on node [ $HOST ] to setup mounts."
else
    echo "Not a compute/login/nas node [ $HOST ]"
    exit
fi

echo " "
echo "Updating /etc/fstab"
echo " "

/bin/sed -i '/:\/data/d'         /etc/fstab  # Remove previous entry for /data

# Test for Infiniband and setup up accordingly
INFINI=''
INFINI=`/usr/sbin/ibhosts 2>&1 | grep 'hpc-s'`

echo "Note: /data mounted via GigE regardless if Infiniband is present or not."
if [ "$INFINI" ];then
    echo "Node has Infiniband [ $HOST ]."
    echo "#nas-7-7.ib:/data        /data                   nfs     rw,noatime,hard,tcp,nosuid,rsize=65520,wsize=65520,vers=3" >> /etc/fstab
    echo "nas-7-7.local:/data     /data                   nfs     rw,noatime,hard,tcp,nosuid,rsize=65520,wsize=65520,vers=3" >> /etc/fstab
else
    echo "Node DOES *NOT* have Infiniband [ $HOST ]."    
    echo "nas-7-7.local:/data     /data                   nfs     rw,noatime,hard,tcp,nosuid,rsize=65520,wsize=65520,vers=3" >> /etc/fstab
fi    

/bin/sed -i '/^$/d'   /etc/fstab     # Remove blank lines

##########################################################################
#### Setup Top Linkies for /dfs1

for linky in {"bio","som"}
do
    if [ ! -h /$linky ]; then
	echo "No /$linky  Linky.  Creating one:  [ /dfs1/$linky  /$linky ]"
	/bin/ln -s /dfs1/$linky  /$linky
    fi
done

##########################################################################
#### Setup Top Linkies for /dfs2

for linky in {"cbcl","tw"}
do
    if [ ! -h /$linky ]; then
	echo "No /$linky  Linky.  Creating one:  [ /dfs2/$linky  /$linky ]"
	/bin/ln -s /dfs2/$linky  /$linky
    fi
done

##########################################################################
#### Setup Auto Mounts Linkies

for linky in {"pub","checkpoint","zot","samlab","jje","ssd-scratch"}
do
    if [ ! -d /$linky ]; then     # Skip if this is the actual mount point
	if [ ! -h /$linky ]; then
	    echo "Linky /$linky does not exits.  Creating /$linky -to- /share/$linky"
	    /bin/ln -s /share/$linky  /$linky
	fi
    fi
done

##########################################################################
#### Enable / Disabled NFS based on /etc/exports

# Make sure if no /etc/exports, to disable NFS
if [ -s /etc/exports ];then
    echo "Enabling NFS - /etc/exports found."
    /sbin/chkconfig nfs on
    /sbin/chkconfig nfslock on
else
    echo "Disabling NFS - /etc/exports is empty."
    /sbin/service nfs stop       &> /dev/null
    /sbin/chkconfig nfs off
    /sbin/chkconfig nfslock off
fi

############################################################################
# Remove old no-longer used linkies from root:
cd /
for linky in {"w1","w2","kevin"}
do
    if test -L $linky
    then
	echo "Un-linking:  $linky"
	/bin/rm $linky
    fi
done

# Cleanup and finish.
/bin/sed -i '/^$/d'   /etc/hosts     # Remove blank lines
/bin/sed -i '/^$/d'   /etc/exports   # Remove blank lines


echo " "
echo "--> All mounts done..."
echo " "
