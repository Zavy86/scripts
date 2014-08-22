#!/bin/bash
#
# Script: git_pull.sh
#
# Description: Pull all the specified Git repositories
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
 printf " Pull all the specified Git repositories\n"
 printf " This script require to be *root* to be executed!\n\n"
 printf " Usage: $0 repository1 repository2 repositoryN\n\n"
}

# check root
if [ "$EUID" -ne 0 ]
then
 display_usage
 exit 1
fi

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

# cycle agrument repository array
for REPOSITORY in "$@"
do
 printf "\nPull repository $REPOSITORY\n"
 su -s /bin/bash $HTUSER -c "cd $HTDOCS$REPOSITORY && git reset --hard && git pull"
done
printf "\nAll done!\n\n"
exit 0
