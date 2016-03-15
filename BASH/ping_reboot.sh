#!/bin/bash
#
# Script: ping_reboot.sh
#
# Description: Ping an host and if fail reboot system
# Author: Manuel Zavatta
# Last update: 15.03.2016
#

# initializations
FAULT=0
REBOOT=1

# display usage
display_usage(){
 printf "\n Zavy's Scripts\n";
 printf " https://github.com/Zavy86/scripts\n\n";
 printf " Ping an host and if fail reboot system\n\n";
 printf " Usage: $0 host [-t test without reboot]\n\n";
}

# check for arguments
if test -z "$1"
then
 display_usage
 exit 1
fi

# check for help
if [[ ("$1" == "-h") || ("$1" == "--help") ]]
then
 display_usage
 exit 0
fi

# check for test
if [[ ("$2" == "-t") ]]
then
 REBOOT=0
fi

# print host
echo "Host $1"

# execute pings
for I in `seq 1 5`;
do
 ping -c 1 $1 > /dev/null
 # check result
 if [ $? -eq 0 ]
 then
  echo "Test $I - Ping successful"
 else
  ((FAULT++))
  echo "Test $I - Ping failed"
 fi
 sleep 1
done

# show failed pings
echo "Failed pings: $FAULT"

# if 3 or more ping fail reboot system
if [ $FAULT -ge 3 ]
then
 # check for test mode
 if [ $REBOOT -eq 1 ]
 then
  echo "Reboot system now"
  /sbin/shutdown -r now
 fi
fi
