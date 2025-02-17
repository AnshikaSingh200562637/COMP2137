#!/bin/bash

# System Information
HOSTNAME=$(hostname)
OS=$(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)
UPTIME=$(uptime -p)

# Hardware Information
CPU=$(lscpu | grep "Model name" | awk -F': ' '{print $2}')
CPU_SPEED=$(lscpu | grep "CPU max" | awk -F': ' '{print $2}')
RAM=$(free -h | awk '/^Mem/ {print $2}')
DISKS=$(lsblk | grep disk | awk '{print $1, $4}')
VIDEO=$(lspci | grep -i vga | awk -F': ' '{print $3}')

# Network Information
FQDN=$(hostname -f)
HOST_ADDRESS=$(hostname -I | awk '{print $1}')
GATEWAY_IP=$(ip route | awk '/default/ {print $3}')
DNS_SERVER=$(cat /etc/resolv.conf | awk '/nameserver/ {print $2}'
# System Status
USERS=$(who | awk '{print $1}' | sort | uniq)
DISK_SPACE=$(df -h | awk '$NF=="/" {print $1, $4}')
PROCESS_COUNT=$(ps -e | wc -l)
LOAD_AVERAGES=$(uptime | awk -F'average: ' '{print $2}')
MEMORY_ALLOC=$(free -h | awk '/^Mem/ {print $3}')

# Listening Network Ports
LISTEN_PORTS=$(ss -tuln | awk '/LISTEN/ {print $5}' | awk -F':|,' '{print $2}' | sort -n | uniq)

# UFW Rules
UFW_RULES=$(ufw status numbered)

# Output
cat <<EOF

-----------------------------------------------------------------------------------------------------------------------------------------------
System Report generated by $USER, $(date)
 
System Information
------------------
Hostname: $HOSTNAME
OS: $OS
Uptime: $UPTIME
 
Hardware Information
--------------------
CPU: $CPU
Speed: $CPU_SPEED
RAM: $RAM
Disks: $DISKS
Video: $VIDEO
 
Network Information
-------------------
FQDN: $FQDN
Host Address: $HOST_ADDRESS
Gateway IP: $GATEWAY_IP
DNS Server: $DNS_SERVER
 
System Status
-------------
Logged in Users: $USERS
Disk Space: $DISK_SPACE
Process Count: $PROCESS_COUNT
Load Averages: $LOAD_AVERAGES
Memory Allocation: $MEMORY_ALLOC
Listening Network Ports: $LISTEN_PORTS
UFW Rules: $UFW_RULES
-------------------------------------------------------------------------------------------------------------------------
EOF
*
