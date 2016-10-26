#!/bin/bash
#
# Script: backup_mysql_dbs.sh
#
# Description: Execute MySQLDump to backup a list of MySQL Databases
# Author: Manuel Zavatta
# Last update: 25.10.2016
#

# display usage
display_usage(){
 printf "\n Zavy's Scripts\n";
 printf " https://github.com/Zavy86/scripts\n\n";
 printf " Execute MySQLDump to backup a list of MySQL Databases\n\n";
 printf " Usage: $0 -h=dbhost -u=dbname -p=dbpass -d=database [-o=/backup/directory] [--lastonly]\n\n";
 printf " Parameters:\n\n";
 printf "   -h, --hostname    database hostname\n";
 printf "   -u, --username    database username\n";
 printf "   -p, --password    database password\n";
 printf "   -d, --database    database name\n";
 printf "   -o, --output-dir  output directory\n";
 printf "   --lastonly        overwrite backups\n\n";
}

# initialization
FILE=""
DIRECTORY="./"
LASTONLY=FALSE
NOW="$(date +"%Y%m%d")"
HOST="$(hostname)"
GZIP="$(which gzip)"
MYSQL="$(which mysql)"
MYSQLDUMP="$(which mysqldump)"

# check for arguments
if test -z "$1"
then
 display_usage
 exit 1
fi

# cycle all arguments
for i in "$@"
do
 case $i in
  --help)
   display_usage
   exit 0
  ;;
  -h=*|--hostname=*)
   DBHOST="${i#*=}"
   shift
  ;;
  -u=*|--username=*)
   DBUSER="${i#*=}"
   shift
  ;;
  -p=*|--password=*)
   DBPASS="${i#*=}"
   shift
  ;;
  -d=*|--database=*)
   DATABASE="${i#*=}"
   shift
  ;;
  -o=*|--output-dir=*)
   DIRECTORY="${i#*=}"
   shift
  ;;
  --lastonly)
   LASTONLY=TRUE
   shift
  ;;
  *)
   echo "UNKNOWN OPTION: ${i}"
  ;;
 esac
 shift
done

# add trailing slash if not exist
[ "${DIRECTORY: -1}" != "/" ] && DIRECTORY="${DIRECTORY}/"

# check connection
if ! $($MYSQL -NBA -h $DBHOST -u $DBUSER -p$DBPASS -D $DATABASE -e 'USE '$DATABASE 2>/dev/null); then
 echo "/!\ Error connecting database.."
 exit 1
fi
 
# start timer
START_TIME=$SECONDS
printf "Backup $DATABASE database\n"
 
# execute sql dump
for TABLE in $($MYSQL -NBA -h $DBHOST -u $DBUSER -p$DBPASS -D $DATABASE -e 'SHOW TABLES')
do 
 # set file name
 if [ "$LASTONLY" = TRUE ]
 then
  mkdir -p "$DIRECTORY"
  FILE="$DIRECTORY$TABLE.sql"
 else
  mkdir -p "$DIRECTORY$NOW"
  FILE="$DIRECTORY$NOW/$TABLE.sql"
 fi
   
 # dump table
 printf "Backup $TABLE table\n"
 $MYSQLDUMP -h $DBHOST -u $DBUSER -p$DBPASS $DATABASE $TABLE > $FILE
done
 
# end timer
ELAPSED_TIME=$(($SECONDS - $START_TIME))
printf "Backup $DATABASE database completed in $ELAPSED_TIME seconds\n"

# normal end
exit 0