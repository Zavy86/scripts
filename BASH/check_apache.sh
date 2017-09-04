#!/bin/bash
#
# Script: check_apache.sh
#
# Description: Check if apache is running if fail restart or reboot system
# Author: Manuel Zavatta
# Last update: 04.09.2017
#

# initializations
HOSTNAME=`hostname -f`
PATH="/bin:/sbin:/usr/bin"
TMPDIR="/tmp/apache-watchdog"
EMAIL=""
REBOOT=1

# display usage
display_usage(){
 printf "\n Zavy's Scripts\n";
 printf " https://github.com/Zavy86/scripts\n\n";
 printf " Check if apache is running if fail restart or reboot system\n\n";
 printf " Usage: $0 mail@domain.tdl [-t test without reboot]\n\n";
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

# set mail
EMAIL=$1


# make temporary directory
mkdir -p $TMPDIR

# check apache status
echo "Check Apache status"

# try to get localhost index file
#if ( wget --timeout=30 -q -P $TMPDIR $CHECKURL )
if ( wget --timeout=30 -q -P $TMPDIR http://localhost/ )
then

	# apache was up
	echo "Apache was up"
	/etc/init.d/apache2 status

	# remove if exist down file
	rm -f ~/.apache-was-down

else

	# if it wasn't down already check to restart apache service
	if [[ ! -f ~/.apache-was-down ]]
	then

		# apache was down
		echo "Apache was down"

		# touch down file
		touch ~/.apache-was-down

		# build crash mail
		echo -n "Apache crashed at " > $TMPDIR/mail
		date >> $TMPDIR/mail
		echo >> $TMPDIR/mail

		# try to restart apache
		echo "Stopping apache service.." >> $TMPDIR/mail
		/etc/init.d/apache2 stop >> $TMPDIR/mail 2>&1
		echo >> $TMPDIR/mail
		echo "Killing apache process.." >> $TMPDIR/mail
		killall -9 apache2 >> $TMPDIR/mail 2>&1
		echo >> $TMPDIR/mail
		echo "Restarting apache service.." >> $TMPDIR/mail
		/etc/init.d/apache2 start >> $TMPDIR/mail 2>&1
		echo >> $TMPDIR/mail
		echo "Apache status" >> $TMPDIR/mail
		/etc/init.d/apache2 status >> $TMPDIR/mail 2>&1
		echo >> $TMPDIR/mail

		# attach last 30 row from error.log
		echo "Last rows from error.log" >> $TMPDIR/mail
		tail -n 30 /var/log/apache2/error.log >> $TMPDIR/mail
		echo >> $TMPDIR/mail

		# send mail
		mail -s "Apache crashed on $HOSTNAME" $EMAIL < $TMPDIR/mail

		# console alert
		echo "Trying to restart Apache process.."
		/etc/init.d/apache2 status

	else

		# if was already down restart server
		echo "Apache continue to be down"

		# remove down file to avoid infinite reboot
		rm -f ~/.apache-was-down

		# build reboot mail
		echo -n "Apache crashed at " > $TMPDIR/mail
		date >> $TMPDIR/mail
		echo >> $TMPDIR/mail
		echo "Rebooting server now.." >> $TMPDIR/mail

		# send mail
		mail -s "Apache crashed on $HOSTNAME" $EMAIL < $TMPDIR/mail

		# console alert
		echo "Killing apache process.."
		killall -9 apache2
		echo "Rebooting server in 1 minute.."
		
		# check for test mode
		if [ $REBOOT -eq 1 ]
		then
			shutdown -r +1 &
		else
			echo "Reboot canceled in test mode.."
		fi
	fi
fi
# remove temp directory
rm -rf $TMPDIR
