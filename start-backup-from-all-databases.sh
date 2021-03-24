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


#define server name
if [ ! $server_name ]; then
	server_name=`hostname`
fi


# check if need to transfer to bucket 1
if [ -f conf/bucket_1.me.conf ]; then
	BUCKET_1=`cat conf/bucket_1.me.conf`
	BUCKET_1=$BUCKET_1|xargs
fi
#BUCKET_1=YOUR_BUCKET_NAME

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

#define remote server path
TARGET_FOLDER=/mysql-auto-backup/$server_name/$BACKUP_FOLDER/
TARGET_PATH=/home$TARGET_FOLDER



# create a dump from all database
echo "*** START DUMP DATABASE"
mysqldump --quick --single-transaction --column-statistics=0 --verbose --all-databases | gzip > $FILEPATH



# transfer backup to server if set
if [ $backup_server1 ]; then
	# sync with remote server 1
	echo "*** SYNC WITH TARGET SERVER 1"
	echo "--> PATH "$backup_server1:$TARGET_PATH
	rsync -avrt --rsync-path="mkdir -p $TARGET_PATH && rsync -avrt" $FILEPATH $backup_server1:$TARGET_PATH
fi


if [ $backup_server2 ]; then
	# sync with remote server 2
	echo "*** SYNC WITH TARGET SERVER 2"
	echo "--> PATH "$backup_server2:$TARGET_PATH
	rsync -avrt --rsync-path="mkdir -p $TARGET_PATH && rsync -avrt" $FILEPATH $backup_server2:$TARGET_PATH
fi


if [ $backup_server3 ]; then
	# sync with remote server 3
	echo "*** SYNC WITH TARGET SERVER 3"
	echo "--> PATH "$backup_server3:$TARGET_PATH
	rsync -avrt --rsync-path="mkdir -p $TARGET_PATH && rsync -avrt" $FILEPATH $backup_server3:$TARGET_PATH
fi



# transfer backup to s3
# first use system s3 with saved detail
if [ $s3_bucketSaved_name ]; then
	# sync with s3 storage server 1
	echo "*** SYNC WITH S3 STORAGE 0 - credential from config"
	echo "--> PATH "s3://$s3_bucketSaved_name$TARGET_FOLDER
	s3cmd sync $FILEPATH s3://$s3_bucketSaved_name$TARGET_FOLDER
fi


# save into 3 different s3 storage with pass credential detail
if [ $s3_bucket1_name ] && [ $s3_bucket1_access ] && [ $s3_bucket1_secret ] && [ $s3_bucket1_endpoint ]; then
	# sync with s3 storage server 1
	echo "*** SYNC WITH S3 STORAGE 1"
	echo "--> PATH " $s3_bucket1_endpoint -- s3://$s3_bucket1_name$TARGET_FOLDER
	s3cmd sync --access_key=$s3_bucket1_access --secret_key=$s3_bucket1_secret --host=$s3_bucket1_endpoint --host-bucket=$s3_bucket1_endpoint $FILEPATH s3://$s3_bucket1_name$TARGET_FOLDER
fi


if [ $s3_bucket2_name ] && [ $s3_bucket2_access ] && [ $s3_bucket2_secret ] && [ $s3_bucket2_endpoint ]; then
	# sync with s3 storage server 2
	echo "*** SYNC WITH S3 STORAGE 2"
	echo "--> PATH "$s3_bucket2_endpoint -- s3://$s3_bucket2_name$TARGET_FOLDER
	s3cmd sync --access_key=$s3_bucket2_access --secret_key=$s3_bucket2_secret --host=$s3_bucket2_endpoint --host-bucket=$s3_bucket2_endpoint $FILEPATH s3://$s3_bucket2_name$TARGET_FOLDER
fi


if [ $s3_bucket3_name ] && [ $s3_bucket3_access ] && [ $s3_bucket3_secret ] && [ $s3_bucket3_endpoint ]; then
	# sync with s3 storage server 3
	echo "*** SYNC WITH S3 STORAGE 3"
	echo "--> PATH "$s3_bucket3_endpoint -- s3://$s3_bucket3_name$TARGET_FOLDER
	s3cmd sync --access_key=$s3_bucket3_access --secret_key=$s3_bucket3_secret --host=$s3_bucket3_endpoint --host-bucket=$s3_bucket3_endpoint $FILEPATH s3://$s3_bucket3_name$TARGET_FOLDER
fi


echo "*** Mission Complete"
