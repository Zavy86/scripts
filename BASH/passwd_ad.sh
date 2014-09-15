#!/bin/bash
#
# Script: passwd_ad.sh
#
# Description: Check if user is in a domain and change domain or local password
# Author: Manuel Zavatta
# Last update: 12.09.2014
#

# display usage
display_usage(){
 printf "\n Zavy's Scripts\n";
 printf " https://github.com/Zavy86/scripts\n\n"
 printf " Check if user is in a domain and change domain or local password\n\n"
 printf " Usage: $0 domain_controller_host optional_domain_users_group\n\n"
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

# domain controller host
DOMAINCONTROLLER=$1

# domain group (space=\s)
if test -z "$2"
then
        DOMAINGROUP="domain\susers"
else
        DOMAINGROUP=$2
fi

# replace spaces with \s
DOMAINGROUP=${DOMAINGROUP//[ ]/\\s}

# check if current user is in the domain group
if groups $USER | grep &>/dev/null $DOMAINGROUP; then
        printf "\nChange your Active Directory password\n\n"
        smbpasswd -U $USER -r $DOMAINCONTROLLER
else
        printf "\nChange your local password\n\n"
        passwd $1
fi

# get command exit status and exit
printf "\n"
CMDEXIT=$?
exit $CMDEXIT
