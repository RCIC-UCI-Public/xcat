#!/bin/bash
#### J. Farran

if [[ `hostname` == "services-xcat" ]];then
    printf "\n -----> Do NOT run this on XCAT Server!   Exiting.\n\n"
    exit -1
fi

#### Update /etc/csh.cshrc and  /etc/csh.login  to read user's own .cshrc & .login files

### Read user .cshrc file                                              
/usr/bin/cat >> /etc/csh.cshrc <<EOF
if ( -e ~/.cshrc ) then
  source ~/.cshrc
endif
EOF

/usr/bin/cat >> /etc/csh.login <<EOF
#### Read user .login file
if ( -e ~/.cshrc ) then
  source ~/.cshrc
endif
EOF
