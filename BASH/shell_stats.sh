#!/bin/bash
#
# Script: shell_stats.sh
#
# Description: Show host statistics
# Author: Manuel Zavatta
# Last update: 22.08.2014
#

# get hostname
HOSTNAME=`hostname -f`

# get IP address
IP=`/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`

# get cpu usage
CPU=`grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print usage "%"}'`
CPU=${CPU%.*}

# get memory usage
RAM=`free -m | grep Mem`
RAM_TOTAL=`echo $RAM | cut -f2 -d' '`
RAM_CURRENT=`echo $RAM | cut -f3 -d' '`
RAM_PERC=$(echo "scale = 2; $RAM_CURRENT/$RAM_TOTAL*100" | bc)
RAM=${RAM_PERC%.*}

# get hard disk usage
HDD=`df -lh | awk '{if ($6 == "/") { print $5 }}' | head -1 | cut -d'%' -f1`

# get uptime
UPTIME=$(</proc/uptime)
UPTIME=${UPTIME%%.*}
UPTIME_S=$((UPTIME%60))
UPTIME_M=$((UPTIME/60%60))
UPTIME_H=$((UPTIME/60/60%24))
UPTIME_D=$((UPTIME/60/60/24))

# show statistics
printf "\nHOST:\t$HOSTNAME\tIP: $IP\n\n"
printf "CPU:\t$CPU %%\tRAM: $RAM %%\tHDD: $HDD %%\n\n"
printf "UPTIME:\t$UPTIME_D days, $UPTIME_H hours, $UPTIME_M minutes\n\n"
exit 0