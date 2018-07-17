#!/bin/bash
### J. Farran

##################################################################
#### Setup Grid Engine.   This script can be re-ran without issues.

SGE_ROOT="/opt/gridengine"

HOST=`hostname -s`

if [[ "$HOST"   =~ "compute-"      ]] || \
    [[ "$HOST"  =~ "hpc-login-"    ]] || \
    [[ "$HOST"  =~ "dfs-"          ]] || \
    [[ "$HOST"  =~ "dfm-"          ]] || \
    [[ "$HOST"  =~ "hpc-lightpath" ]] || \
    [[ "$HOST"  =~ "services"      ]] || \
    [[ "$HOST"  =~ "nas-"          ]]; then
    echo "Node check pass."
else
    echo " "
    echo "*** Error ****"
    echo "Cannot install on this node [`hostname`].   Exiting."
    exit -1
fi

### It is critical that we remove any old sge references.
### Cleanup of old stuff first.
find /etc -maxdepth 1 -name "*sgeexecd*" -exec echo Removing {} \;  -exec rm {} \;
find /etc -maxdepth 1 -name "sge-*"      -exec echo Removing {} \;  -exec rm {} \;
find /etc -maxdepth 1 -name "sge.*"      -exec echo Removing {} \;  -exec rm {} \;
find /etc -maxdepth 1 -name "ge.*"       -exec echo Removing {} \;  -exec rm {} \;

if [ ! -d $SGE_ROOT ];then
    ## We assume SGE is not running ( first image )
    echo "Found NO $SGE_ROOT   Creating one from tar image."
    echo " "
    cd /opt
    ## Will untar to /opt/gridengine
    /bin/cp -f /data/xcat/node-setup/node-files/gridengine-8.1.9-centos-6.9.tar .
    /bin/tar -vxf gridengine-8.1.9-centos-6.9.tar

    cd /opt/gridengine
    /bin/cp -f /data/xcat/node-setup/node-files/gridengine-default.tar .
    ## Will untar to default 'gridengine'
    /bin/tar -vxf gridengine-default.tar
fi

if [ ! -d /var/spool/sge ];then
    echo "Found NO /var/spool/sge"
    echo "Creating new one."
    echo " "
    /bin/mkdir -p      /var/spool/sge
    /bin/chown -R 400  /var/spool/sge
    /bin/chgrp -R 400  /var/spool/sge
fi

if [ ! -f /opt/gridengine/default/common/accounting ];then
    echo "Creating link: /opt/gridengine/default/common/accounting"
    /bin/ln -s /data/hpc/sge/accounting  /opt/gridengine/default/common/accounting
fi

if [ ! -f /opt/gridengine/default/common/reporting ];then
    echo "Creating link: /opt/gridengine/default/common/reporting"
    /bin/ln -s /data/hpc/sge/reporting  /opt/gridengine/default/common/reporting
fi

SGE_ACCOUNT=`cat /etc/passwd | grep "^sge:x:"`
if [ -z $SGE_ACCOUNT ];then
    echo "No SGE account.  Creating one."
    echo "sge:x:400:400:GridEngine:/opt/gridengine:/bin/true" >> /etc/passwd
fi

sync;sync;sync

/bin/cp -f $SGE_ROOT/default/common/sgeexecd  /etc/init.d/sgeexecd.HPC
/sbin/chkconfig  sgeexecd.HPC on

/bin/cp -f /data/xcat/node-setup/node-files/etc/profile.d/sge.*  /etc/profile.d/
/bin/cp -f /data/xcat/node-setup/node-files/dot-sge_qstat        /root/.sge_qstat

/bin/cp -f /data/hpc/sge/*.sh          $SGE_ROOT
/bin/cp -f /data/hpc/sge/qrsh          $SGE_ROOT/bin
/bin/cp -f /data/hpc/sge/qlogin        $SGE_ROOT/bin

/bin/cp -f /data/hpc/sge/sge_request   $SGE_ROOT/default/common

/bin/chown -R 400  $SGE_ROOT
/bin/chgrp -R 400  $SGE_ROOT
