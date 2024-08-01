#!/bin/bash

set -e

VERBOSE=false

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -verbose) VERBOSE=true ;;
        -name) DESIRED_NAME="$2"; shift ;;
        -ip) DESIRED_IP="$2"; shift ;;
        -hostentry) HOSTENTRY_NAME="$2"; HOSTENTRY_IP="$3"; shift 2 ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

log() {
    if $VERBOSE; then
        echo "$1"
    fi
    logger "$1"
}

update_hostname() {
    local current_hostname
    current_hostname=$(hostname)
    if [ "$current_hostname" != "$DESIRED_NAME" ]; then
        log "Updating hostname to $DESIRED_NAME"
        echo "$DESIRED_NAME" > /etc/hostname
        hostnamectl set-hostname "$DESIRED_NAME"
        sed -i "s/$current_hostname/$DESIRED_NAME/g" /etc/hosts
    else
        log "Hostname already set to $DESIRED_NAME"
    fi
}

update_ip() {
    local current_ip
    current_ip=$(hostname -I | awk '{print $1}')
    if [ "$current_ip" != "$DESIRED_IP" ]; then
        log "Updating IP address to $DESIRED_IP"
        # Assume interface is eth0, adjust as necessary
        sed -i "s/$current_ip/$DESIRED_IP/g" /etc/netplan/01-netcfg.yaml
        netplan apply
        sed -i "s/$current_ip/$DESIRED_IP/g" /etc/hosts
    else
        log "IP address already set to $DESIRED_IP"
    fi
}

update_hostentry() {
    if ! grep -q "$HOSTENTRY_NAME" /etc/hosts; then
        log "Adding $HOSTENTRY_NAME with IP $HOSTENTRY_IP to /etc/hosts"
        echo "$HOSTENTRY_IP $HOSTENTRY_NAME" >> /etc/hosts
    else
        log "$HOSTENTRY_NAME already in /etc/hosts"
    fi
}

trap "" TERM HUP INT

if [ ! -z "$DESIRED_NAME" ]; then
    update_hostname
fi

if [ ! -z "$DESIRED_IP" ]; then
    update_ip
fi

if [ ! -z "$HOSTENTRY_NAME" ] && [ ! -z "$HOSTENTRY_IP" ]; then
    update_hostentry
fi
