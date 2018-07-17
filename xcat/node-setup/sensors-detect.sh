#!/bin/bash                                                                                                                                                
#### Garr Updegraff,  2014-09-09

SENSORS_DETECT="/usr/sbin/sensors-detect"
YES_PROG="/usr/bin/yes"

HOST=`hostname`
echo "$HOST -- running sensors-detect..."

CMD="$YES_PROG '' | $SENSORS_DETECT"
echo "$CMD"

if [ -x $YES_PROG   -a  -x $SENSORS_DETECT ];  then
    $YES_PROG '' | $SENSORS_DETECT
else
    echo "Error: Executable missing on $HOST:
    $CMD"
fi

