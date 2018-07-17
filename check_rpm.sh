#!/bin/bash

rpm -qa > /tmp/mylocalrpms

mylocalrpms=`cat /tmp/mylocalrpms`

rm -fr /tmp/rpm_compare.log
touch /tmp/rpm_compare.log
echo $mylocalrpms


for j in $mylocalrpms
do
#   echo "grepping $j from local to HPC"
   sleep 1
   grep -qx $j /tmp/hpc_rpm_log
   if [ $? -ne 0 ];then
     echo "rpm $j is not there" | tee -a /tmp/rpm_compare.log 

    else
     echo "rpm $j match" | tee -a /tmp/rpm_compare.log


   fi 



done

Total_match_rpm=`grep -v "not there" /tmp/rpm_compare.log | wc -l`
Total_unmatch_rpm=`grep "not there" /tmp/rpm_compare.log | wc -l`

echo "RPM match: $Total_match_rpm"
echo "RPM do not match: $Total_unmatch_rpm"
