#!/bin/bash
#==========================================================================
#
# Script: shell_stats.sh
#
# Description: Show Host Statistics
# Author: Manuel Zavatta
# Last update: 21.08.2014
#
#==========================================================================
# HOSTNAME
HOSTNAME=`hostname -f`
# IP ADDRESS
IP=`/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
# CPU
#echo `top -b -n1 | grep "Cpu(s)" | awk '{print $2 + $4}'`
CPU=`grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print usage "%"}'`
CPU=${CPU%.*}
# RAM
RAM=`free -m | grep Mem`
RAM_TOTAL=`echo $RAM | cut -f2 -d' '`
RAM_CURRENT=`echo $RAM | cut -f3 -d' '`
RAM_PERC=$(echo "scale = 2; $RAM_CURRENT/$RAM_TOTAL*100" | bc)
RAM=${RAM_PERC%.*}
# HDD
HDD=`df -lh | awk '{if ($6 == "/") { print $5 }}' | head -1 | cut -d'%' -f1`
# UPTIME
UPTIME=$(</proc/uptime)
UPTIME=${UPTIME%%.*}
UPTIME_S=$((UPTIME%60))
UPTIME_M=$((UPTIME/60%60))
UPTIME_H=$((UPTIME/60/60%24))
UPTIME_D=$((UPTIME/60/60/24))
# SHOW
echo ""
echo -e "HOST:\t$HOSTNAME\tIP: $IP"
echo ""
echo -e "CPU:\t$CPU % \tRAM: $RAM % \tHDD: $HDD %"
echo ""
echo -e "UPTIME:\t$UPTIME_D days, $UPTIME_H hours, $UPTIME_M minutes"
echo ""
#==========================================================================