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
 printf " Send a fortune cookie via mail\n\n"
 printf " Usage: $0 recipient1@mail.com recipient2@mail.com recipientN@mail.com \n\n"
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

# loop recipients
for i in "$@"; do
(
 printf "<html><body><pre style='font: monospace'>";
 /usr/games/fortune -s | /usr/games/cowsay -f bunny
 printf "</pre></body></html>";
) | mail -s "Fortune Cookie" -a "Content-type: text/html;" $i -- -f "Sensei <serverlinux@cogne.com>"
done