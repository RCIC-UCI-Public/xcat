#!/bin/bash
yum grouplist -v | grep "^ " | cut -f 2 -d \( | sed -e "s/)//" > /tmp/yum.grouplist

for GROUP in `cat /tmp/yum.grouplist`
do 
    name=`yum groupinfo "$GROUP" |grep -i $1`
    if [[ $? -eq  0 ]] # $? is status of last cmd in pipe ie matched
    then
        echo $GROUP = $name  
    fi
done
rm /tmp/yum.grouplist
