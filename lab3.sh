#!/bin/bash

VERBOSE_MODE=false

if [[ "$1" == "-verbose" ]]; then
    VERBOSE_MODE=true
    shift
fi

SCP_OPTIONS=""
SSH_OPTIONS=""

if $VERBOSE_MODE; then
    SCP_OPTIONS="-v"
    SSH_OPTIONS="-v"
fi

scp $SCP_OPTIONS configure-host.sh remoteadmin@server1-mgmt:/root
ssh $SSH_OPTIONS remoteadmin@server1-mgmt -- /root/configure-host.sh -name loghost -ip 192.168.16.3 -hostentry webhost 192.168.16.4 $([ $VERBOSE_MODE == true ] && echo "-verbose")
scp $SCP_OPTIONS configure-host.sh remoteadmin@server2-mgmt:/root
ssh $SSH_OPTIONS remoteadmin@server2-mgmt -- /root/configure-host.sh -name webhost -ip 192.168.16.4 -hostentry loghost 192.168.16.3 $([ $VERBOSE_MODE == true ] && echo "-verbose")

./configure-host.sh -hostentry loghost 192.168.16.3 $([ $VERBOSE_MODE == true ] && echo "-verbose")
./configure-host.sh -hostentry webhost 192.168.16.4 $([ $VERBOSE_MODE == true ] && echo "-verbose")
