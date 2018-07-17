#!/bin/bash
#### J. Farran
#### 4/18

if [[ $HOST == "services-xcat" ]];then
    echo " "
    echo "-----> Do NOT run this on XCAT Server! Exiting."
    exit -1
fi

##################################################################
### Setup local repos
/data/node-setup/setup-local-repos.sh


##################################################################
### Update ( yummie yummie )

printf "\n ---> Redhat Release:\n"
cat /etc/redhat-release 

printf  "\n ---> Yum Cleanup.\n"

yum clean metadata
yum clean all
yum-complete-transaction 

printf '\n\n%80s\n' | tr ' ' '='           
printf  " ---> Yum Update.\n"

/usr/bin/yum -y --skip-broken update \
    --exclude="*kernel*"             \
    --exclude="*OFED*"               \
    --exclude="*libibverbs*"         \
    --exclude="*libmlx4*"            \
    --exclude="*mstflint*"           \
    --exclude="*dracut*"             \
    --exclude="environment-modules"  \
    --exclude="emacs-auto-complete"

printf '\n%80s\n\n' | tr ' ' '='

yum-complete-transaction >& /dev/null

##########################################################################
#### Make sure these are never installed

printf "\n ---> Removing NOT NEEDED packages (in case they were installed).\n"
printf   " ----------------------------------------------------------------\n\n"
yum remove -y  environment-modules
yum remove -y  cpuspeed
yum remove -y  emacs-auto-complete
yum remove -y  R-core
yum remove -y  gnome-screensaver 
yum remove -y  gnome-power-manager
yum remove -y  mvapich2-2.0-1.x86_64 
yum remove -y  openmpi-1.8.2rc6-1.x86_64
yum remove -y  pulseaudio
