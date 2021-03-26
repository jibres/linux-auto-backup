#!/usr/bin/env bash
# shellcheck disable=SC1091
cd "$(dirname "${BASH_SOURCE[0]}")"

# include yaml reader script
source script/yaml.sh
# include telegram reader script
source script/telegram.sh


# Simple bash script to backup sql database into file with mysqldump and transfer it to another server
#
#
# Execute yaml reader
create_variables conf/config[$(hostname)].me.yaml


#define server name
if [ ! $server_name ]; then
	server_name=`hostname`
fi


BUSY=busy.log
if test -f "$BUSY"; then
	echo "it's busy from last action on db!"
    echo "it's busy from last action on db!" >> log/$(date +%Y%m%d-%H:%M)-db-busy.log
	telegram_send "🧨 $server_name busy from last opr on db backup! $BACKUP_FOLDER"
	exit
fi
# save log
echo 'backup db --> '$(date +%Y%m%d-%H:%M:%S)' --> start' >> $BUSY


# save start date for backup
NOTIF="<b>"$server_title"</b> <code>$BACKUP_FOLDER</code>%0A"
NOTIF+=$(date +%Y/%m/%d)" "$(date +%H:%M:%S)"%0A"


#file name for backup
FILE_UNIQUE_NAME="NA"

case $BACKUP_FOLDER in

  hourly)
    FILE_UNIQUE_NAME=-h$(date +%H)
    ;;

  daily)
    FILE_UNIQUE_NAME=-d$(date +%d)
    ;;

  monthly)
    FILE_UNIQUE_NAME=-m$(date +%m)
    ;;
	
  *)
    echo -n "*** unknown backup mode - create now"
	FILE_UNIQUE_NAME=-now
	BACKUP_FOLDER=now-$(date +%Y%m%d-%H%M%S)
    ;;
esac



#define file name
FILENAME=backup[$server_name]-alldb$FILE_UNIQUE_NAME.sql.gz


#define file path
FOLDER_PATH="$(pwd)/$BACKUP_FOLDER"
# create folder if not exist
mkdir -p $FOLDER_PATH
# create file full path
FILEPATH=$FOLDER_PATH/$FILENAME



# create a dump from all database
echo "*** START DUMP DATABASE"
mysqldump --quick --single-transaction --column-statistics=0 --verbose --all-databases | gzip > $FILEPATH

echo 'backup db --> '$(date +%Y%m%d-%H:%M:%S)' --> finish' >> $BUSY
NOTIF+="🆗 $(date +%M:%S) <code>DB Backup</code>%0A"

echo "*** Backup Complete"
