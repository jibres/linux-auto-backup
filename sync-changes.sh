#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC1091
#
# Configure
set -e
cd "$(dirname "${BASH_SOURCE[0]}")"

# include yaml reader script
source script/yaml.sh
#
# Simple bash script to backup sql database into file with mysqldump and transfer it to another server
#
#
# Execute yaml reader
create_variables conf/config[$(hostname)].me.yaml

# save log
echo 'sync --> '$(date +%Y%m%d-%H:%M:%S)' --> start' >> busy.log


#define server name
if [ ! $server_name ]; then
	server_name=`hostname`
fi



# address of backup folder, usually go one folder up from this folder
BACKUP_FROM=$(pwd)/../

#define remote server path
TARGET_FOLDER=/jib-backup/$server_name/
TARGET_PATH=/home$TARGET_FOLDER


# transfer backup to server if set
if [ $backup_server1 ]; then
	# sync with remote server 1
	echo "*** SYNC WITH TARGET SERVER 1"
	echo "--> PATH "$backup_server1:$TARGET_PATH
	# save log
	echo 'sync --> '$(date +%Y%m%d-%H:%M:%S)' --> server 1 --> '$backup_server1:$TARGET_PATH >> busy.log
	
	rsync -avrt --rsync-path="mkdir -p $TARGET_PATH && rsync -avrt" $BACKUP_FROM $backup_server1:$TARGET_PATH
fi


if [ $backup_server2 ]; then
	# sync with remote server 2
	echo "*** SYNC WITH TARGET SERVER 2"
	echo "--> PATH "$backup_server2:$TARGET_PATH
	# save log
	echo 'sync --> '$(date +%Y%m%d-%H:%M:%S)' --> server 2 --> '$backup_server2:$TARGET_PATH >> busy.log
	
	rsync -avrt --rsync-path="mkdir -p $TARGET_PATH && rsync -avrt" $BACKUP_FROM $backup_server2:$TARGET_PATH
fi


if [ $backup_server3 ]; then
	# sync with remote server 3
	echo "*** SYNC WITH TARGET SERVER 3"
	echo "--> PATH "$backup_server3:$TARGET_PATH
	# save log
	echo 'sync --> '$(date +%Y%m%d-%H:%M:%S)' --> server 3 --> '$backup_server3:$TARGET_PATH >> busy.log
	
	rsync -avrt --rsync-path="mkdir -p $TARGET_PATH && rsync -avrt" $BACKUP_FROM $backup_server3:$TARGET_PATH
fi



# transfer backup to s3
# first use system s3 with saved detail
if [ $s3_bucketSaved_name ]; then
	# sync with s3 storage server 1
	echo "*** SYNC WITH S3 STORAGE 0 - credential from config"
	echo "--> PATH "s3://$s3_bucketSaved_name$TARGET_FOLDER
	# save log
	echo 'sync --> '$(date +%Y%m%d-%H:%M:%S)' --> bucket Saved --> s3://'$s3_bucketSaved_name$TARGET_FOLDER >> busy.log
	
	s3cmd sync $BACKUP_FROM s3://$s3_bucketSaved_name$TARGET_FOLDER
fi


# save into 3 different s3 storage with pass credential detail
if [ $s3_bucket1_name ] && [ $s3_bucket1_access ] && [ $s3_bucket1_secret ] && [ $s3_bucket1_endpoint ]; then
	# sync with s3 storage server 1
	echo "*** SYNC WITH S3 STORAGE 1"
	echo "--> PATH " $s3_bucket1_endpoint -- s3://$s3_bucket1_name$TARGET_FOLDER
	# save log
	echo 'sync --> '$(date +%Y%m%d-%H:%M:%S)' --> bucket 1 --> '$s3_bucket1_endpoint' -- s3://'$s3_bucket1_name$TARGET_FOLDER >> busy.log
	
	s3cmd sync --access_key=$s3_bucket1_access --secret_key=$s3_bucket1_secret --host=$s3_bucket1_endpoint --host-bucket=$s3_bucket1_endpoint $BACKUP_FROM s3://$s3_bucket1_name$TARGET_FOLDER
fi


if [ $s3_bucket2_name ] && [ $s3_bucket2_access ] && [ $s3_bucket2_secret ] && [ $s3_bucket2_endpoint ]; then
	# sync with s3 storage server 2
	echo "*** SYNC WITH S3 STORAGE 2"
	echo "--> PATH "$s3_bucket2_endpoint -- s3://$s3_bucket2_name$TARGET_FOLDER
	# save log
	echo 'sync --> '$(date +%Y%m%d-%H:%M:%S)' --> bucket 2 --> '$s3_bucket2_endpoint' -- s3://'$s3_bucket2_name$TARGET_FOLDER >> busy.log
	
	s3cmd sync --access_key=$s3_bucket2_access --secret_key=$s3_bucket2_secret --host=$s3_bucket2_endpoint --host-bucket=$s3_bucket2_endpoint $BACKUP_FROM s3://$s3_bucket2_name$TARGET_FOLDER
fi


if [ $s3_bucket3_name ] && [ $s3_bucket3_access ] && [ $s3_bucket3_secret ] && [ $s3_bucket3_endpoint ]; then
	# sync with s3 storage server 3
	echo "*** SYNC WITH S3 STORAGE 3"
	echo "--> PATH "$s3_bucket3_endpoint -- s3://$s3_bucket3_name$TARGET_FOLDER
	# save log
	echo 'sync --> '$(date +%Y%m%d-%H:%M:%S)' --> bucket 3 --> '$s3_bucket3_endpoint' -- s3://'$s3_bucket3_name$TARGET_FOLDER >> busy.log
	
	s3cmd sync --access_key=$s3_bucket3_access --secret_key=$s3_bucket3_secret --host=$s3_bucket3_endpoint --host-bucket=$s3_bucket3_endpoint $BACKUP_FROM s3://$s3_bucket3_name$TARGET_FOLDER
fi

# save log
echo 'sync --> '$(date +%Y%m%d-%H:%M:%S)' --> finish **********' >> busy.log
mkdir -p log
mv busy.log log/archive-h$(date +%Y%m%d-%H:%M).log

echo "*** Mission Complete"
