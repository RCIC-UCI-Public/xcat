#!/bin/bash
#### J. Farran
#### 10/13
#### 5/18  For xcat
##################################################################
### Setup the node's root .bashrc file
### This script can be re-ran without issue

if [[ `hostname` == "services-xcat" ]];then
    printf "\n -----> Do NOT run this on XCAT Server!   Exiting.\n\n"
    exit -1
fi

FILE=/root/.bashrc

##########################################################################
### First cleanup
/bin/sed -i '/shell-syswide-setup/d'     $FILE
/bin/sed -i '/VISUAL/d'                  $FILE
/bin/sed -i '/EDITOR/d'                  $FILE
/bin/sed -i '/HPC_CURRENT_KERNEL_RPM/d'  $FILE

### Add entries
echo ". /data/shell-syswide-setup/system-wide-bashrc" >> $FILE
echo "export VISUAL=emacs"                            >> $FILE
echo "export EDITOR=emacs"                            >> $FILE
