#!/usr/bin/env bash
cd "$(dirname "${BASH_SOURCE[0]}")"

# include yaml reader script
source script/yaml.sh
# include telegram reader script
source script/telegram.sh

# backup from LEMP. Nginx & PHP & MySQL & ...
source backup-LEMP.sh

#
# Simple bash script to backup sql database into file with mysqldump and transfer it to another server
#
#
# Execute yaml reader
create_variables conf/config[$(hostname)].me.yaml

#define server name
if [ ! $server_name ]; then
	server_name=`hostname`
fi

if [ ! $SECONDS ]; then
	SECONDS=0
fi



# start from  backup
if [ ! $BUSY ]; then

	BUSY=busy.log
	if test -f "$BUSY"; then
		echo "it's busy from last action!"
		mkdir -p log
		echo "it's busy from last action!" >> log/$(date +%Y%m%d-%H:%M)-sync-busy.log
		telegram_send "🆘 $server_name busy from last opr on sync! $BACKUP_FOLDER"
		exit
	fi

	NOTIF+="<b>"$server_title"</b> <u>$BACKUP_FOLDER</u>%0A"
	NOTIF+=$(date +%Y/%m/%d)" "$(date +%H:%M:%S)"%0A"

fi

# save log
echo 'sync --> '$(date +%Y%m%d-%H:%M:%S)' --> start' >> $BUSY


# address of backup folder, usually go one folder up from this folder
BACKUP_FROM=$(pwd)/../

#define remote server path
TARGET_FOLDER=/backup/$server_name/
TARGET_PATH=/home$TARGET_FOLDER


# transfer backup to server if set
if [ $backup_server1 ]; then
	# sync with remote server 1
	echo "*** SYNC WITH TARGET SERVER 1"
	echo "--> PATH "$backup_server1:$TARGET_PATH
	# save log
	echo 'sync --> '$(date +%Y%m%d-%H:%M:%S)' --> server 1 --> '$backup_server1:$TARGET_PATH >> $BUSY
		
	rsync -avrt --rsync-path="mkdir -p $TARGET_PATH && rsync -avrt" $BACKUP_FROM $backup_server1:$TARGET_PATH
	
	NOTIF+="🖥️ $(date +%M:%S) <code>"$backup_server1"</code>%0A"
fi


if [ $backup_server2 ]; then
	# sync with remote server 2
	echo "*** SYNC WITH TARGET SERVER 2"
	echo "--> PATH "$backup_server2:$TARGET_PATH
	# save log
	echo 'sync --> '$(date +%Y%m%d-%H:%M:%S)' --> server 2 --> '$backup_server2:$TARGET_PATH >> $BUSY
		
	rsync -avrt --rsync-path="mkdir -p $TARGET_PATH && rsync -avrt" $BACKUP_FROM $backup_server2:$TARGET_PATH
	
	NOTIF+="🖥️ $(date +%M:%S) <code>"$backup_server2"</code>%0A"
fi


if [ $backup_server3 ]; then
	# sync with remote server 3
	echo "*** SYNC WITH TARGET SERVER 3"
	echo "--> PATH "$backup_server3:$TARGET_PATH
	# save log
	echo 'sync --> '$(date +%Y%m%d-%H:%M:%S)' --> server 3 --> '$backup_server3:$TARGET_PATH >> $BUSY
		
	rsync -avrt --rsync-path="mkdir -p $TARGET_PATH && rsync -avrt" $BACKUP_FROM $backup_server3:$TARGET_PATH
	
	NOTIF+="🖥️ $(date +%M:%S) <code>"$backup_server3"</code>%0A"
fi



# transfer backup to s3
# first use system s3 with saved detail
if [ $s3_bucketSaved_name ]; then
	# sync with s3 storage server 1
	echo "*** SYNC WITH S3 STORAGE 0 - credential from config"
	echo "--> PATH "s3://$s3_bucketSaved_name$TARGET_FOLDER
	# save log
	echo 'sync --> '$(date +%Y%m%d-%H:%M:%S)' --> bucket Saved --> s3://'$s3_bucketSaved_name$TARGET_FOLDER >> $BUSY
	
	s3cmd sync --delete-removed $BACKUP_FROM s3://$s3_bucketSaved_name$TARGET_FOLDER
	
	NOTIF+="♨️ $(date +%M:%S) <code>"$s3_bucketSaved_title"</code>%0A"
fi


# save into 3 different s3 storage with pass credential detail
if [ $s3_bucket1_name ] && [ $s3_bucket1_access ] && [ $s3_bucket1_secret ] && [ $s3_bucket1_endpoint ]; then
	# sync with s3 storage server 1
	echo "*** SYNC WITH S3 STORAGE 1"
	echo "--> PATH " $s3_bucket1_endpoint -- s3://$s3_bucket1_name$TARGET_FOLDER
	# save log
	echo 'sync --> '$(date +%Y%m%d-%H:%M:%S)' --> bucket 1 --> '$s3_bucket1_endpoint' -- s3://'$s3_bucket1_name$TARGET_FOLDER >> $BUSY
		
	s3cmd sync --delete-removed --access_key=$s3_bucket1_access --secret_key=$s3_bucket1_secret --host=$s3_bucket1_endpoint --host-bucket=$s3_bucket1_endpoint $BACKUP_FROM s3://$s3_bucket1_name$TARGET_FOLDER
	
	NOTIF+="🚀 $(date +%M:%S) <code>"$s3_bucket1_title"</code>%0A"
fi


if [ $s3_bucket2_name ] && [ $s3_bucket2_access ] && [ $s3_bucket2_secret ] && [ $s3_bucket2_endpoint ]; then
	# sync with s3 storage server 2
	echo "*** SYNC WITH S3 STORAGE 2"
	echo "--> PATH "$s3_bucket2_endpoint -- s3://$s3_bucket2_name$TARGET_FOLDER
	# save log
	echo 'sync --> '$(date +%Y%m%d-%H:%M:%S)' --> bucket 2 --> '$s3_bucket2_endpoint' -- s3://'$s3_bucket2_name$TARGET_FOLDER >> $BUSY
		
	s3cmd sync --delete-removed --access_key=$s3_bucket2_access --secret_key=$s3_bucket2_secret --host=$s3_bucket2_endpoint --host-bucket=$s3_bucket2_endpoint $BACKUP_FROM s3://$s3_bucket2_name$TARGET_FOLDER
	
	NOTIF+="🚀 $(date +%M:%S) <code>"$s3_bucket2_title"</code>%0A"
fi


if [ $s3_bucket3_name ] && [ $s3_bucket3_access ] && [ $s3_bucket3_secret ] && [ $s3_bucket3_endpoint ]; then
	# sync with s3 storage server 3
	echo "*** SYNC WITH S3 STORAGE 3"
	echo "--> PATH "$s3_bucket3_endpoint -- s3://$s3_bucket3_name$TARGET_FOLDER
	# save log
	echo 'sync --> '$(date +%Y%m%d-%H:%M:%S)' --> bucket 3 --> '$s3_bucket3_endpoint' -- s3://'$s3_bucket3_name$TARGET_FOLDER >> $BUSY
		
	s3cmd sync --delete-removed --access_key=$s3_bucket3_access --secret_key=$s3_bucket3_secret --host=$s3_bucket3_endpoint --host-bucket=$s3_bucket3_endpoint $BACKUP_FROM s3://$s3_bucket3_name$TARGET_FOLDER
	
	NOTIF+="🚀 $(date +%M:%S) <code>"$s3_bucket3_title"</code>%0A"
fi

# save log
echo 'sync --> '$(date +%Y%m%d-%H:%M:%S)' --> finish **********' >> $BUSY

#NOTIF+="⏱ $(date +%M:%S) Done"
duration=$SECONDS
NOTIF+="⏱ Done <i>$(($duration / 60)):$(($duration % 60))</i>"

telegram_send "$NOTIF"

mkdir -p log
mv $BUSY log/$(date +%Y%m%d-%H:%M)-done.log

echo "*** Mission Complete"
