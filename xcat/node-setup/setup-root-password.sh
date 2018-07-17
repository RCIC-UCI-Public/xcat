#!/bin/bash
#### J. Farran
#### 12/13

if [[ `hostname` == "services-xcat" ]];then
    printf "\n -----> Do NOT run this on XCAT Server!   Exiting.\n\n"
    exit -1
fi

##########################################################################
/usr/sbin/usermod -p '$6$RWn5s0EM$zhJiQxj/3oe5mjwq/sC1x8NCfLAdmEkr.cDkTeIG91F7JLkgDj2mV8jsfyn9WbDho5k5LqoDa.YTLSshTJWnD1'  root

