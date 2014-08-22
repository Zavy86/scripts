#!/bin/bash
#
# Script: htdocs_permissions.sh
#
# Description: Repair all htdocs files permissions
# Author: Manuel Zavatta
# Last update: 22.08.2014
#

# htdocs and htuser
HTDOCS="/var/www/";
HTUSER="www-data";

# display usage
display_usage(){
 printf "\n Zavy's Scripts\n";
 printf " https://github.com/Zavy86/scripts\n\n"
 printf " Repair all htdocs files permissions\n"
 printf " This script require to be *root* to be executed!\n\n"
}

# check root
if [ "$EUID" -ne 0 ]
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

# repair htdocs permissions
printf "\nRepair owner and permissions of $HTDOCS\n\n"
chown -R $HTUSER:$HTUSER $HTDOCS
chmod -R 755 $HTDOCS
exit 0
