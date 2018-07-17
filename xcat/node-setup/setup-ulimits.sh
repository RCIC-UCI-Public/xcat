#!/bin/bash
### J. Farran
### Update ulimits.conf 

FILE=/etc/security/limits.conf

# Remove any old entries
/bin/sed -i '/* hard/d'   $FILE
/bin/sed -i '/* soft/d'   $FILE

cat >> $FILE <<EOF
* soft memlock unlimited
* hard memlock unlimited
* soft nofile 8000
* hard nofile 8192
* soft nproc  8000
* hard nproc  200000
* soft stack  30720
* hard stack  51200
EOF

FILE=/etc/security/limits.d/90-nproc.conf

if [ -f $FILE ];then

    /bin/sed -i 's/soft    nproc     1024/soft    nproc     9999/g'   $FILE

fi