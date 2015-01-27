#!/bin/bash
#
# Script: rsync.sh
#
# Description: Syncronize folders with rSync
# Author: Manuel Zavatta
# Last update: 27.01.2015
#

# display usage
display_usage(){
 printf "\n Zavy's Scripts\n";
 printf " https://github.com/Zavy86/scripts\n\n"
 printf " Syncronize folders with rSync\n\n"
 printf " Usage: $0 /target /destination \n\n"
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

# call rSync
rsync -a --delete --progress $1 $2