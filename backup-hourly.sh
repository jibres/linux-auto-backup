# Simple bash script to backup sql database into file with mysqldump and transfer it to another server

#define server name
ZONE=`hostname`

if [ -f conf/hostname.me.conf ]; then
	ZONE=`cat conf/hostname.me.conf`
	ZONE=$ZONE|xargs
fi
#ZONE=YOUR_SERVER_CUSTOM_NAME


# check if need to transfer to bucket 1
if [ -f conf/bucket_1.me.conf ]; then
	BUCKET_1=`cat conf/bucket_1.me.conf`
	BUCKET_1=$BUCKET_1|xargs
fi
#BUCKET_1=YOUR_BUCKET_NAME


# check if need to transfer to baclup server
if [ -f conf/backup_server_1.me.conf ]; then
	BACKUP_SERVER_1=`cat conf/backup_server_1.me.conf`
	BACKUP_SERVER_1=$BACKUP_SERVER_1|xargs
fi
#BACKUP_SERVER_1=root@1.2.3.4


# check if need to transfer to baclup server
if [ -f conf/backup_server_2.me.conf ]; then
	BACKUP_SERVER_2=`cat conf/backup_server_2.me.conf`
	BACKUP_SERVER_2=$BACKUP_SERVER_2|xargs
fi
#BACKUP_SERVER_2=root@1.2.3.4


# check if need to transfer to baclup server
if [ -f conf/backup_server_3.me.conf ]; then
	BACKUP_SERVER_3=`cat conf/backup_server_3.me.conf`
	BACKUP_SERVER_3=$BACKUP_SERVER_3|xargs
fi
#BACKUP_SERVER_3=root@1.2.3.4


#define file name
FILENAME=backup[$ZONE]-alldb-h$(date +%H).sql.gz

#define folder name
BACKUP_FOLDER="hourly"

#define file path
FOLDER_PATH="$(pwd)/$BACKUP_FOLDER"
# create folder if not exist
mkdir -p $FOLDER_PATH
# create file full path
FILEPATH=$FOLDER_PATH/$FILENAME

#define remote server path
TARGET_FOLDER=/mysql-auto-backup/$ZONE/$BACKUP_FOLDER/
TARGET_PATH=/home$TARGET_FOLDER



# create a dump from all database
echo "*** START DUMP DATABASE"
mysqldump --quick --single-transaction --column-statistics=0 --all-databases | gzip > $FILEPATH


if [ $BACKUP_SERVER_1 ]; then
	# sync with remote server 1
	echo "*** SYNC WITH TARGET SERVER 1"
	echo $BACKUP_SERVER_1:$TARGET_PATH
	rsync -avrt --rsync-path="mkdir -p $TARGET_PATH && rsync -avrt" $FILEPATH $BACKUP_SERVER_1:$TARGET_PATH
fi


if [ $BACKUP_SERVER_2 ]; then
	# sync with remote server 2
	echo "*** SYNC WITH TARGET SERVER 2"
	echo $BACKUP_SERVER_2:$TARGET_PATH
	rsync -avrt --rsync-path="mkdir -p $TARGET_PATH && rsync -avrt" $FILEPATH $BACKUP_SERVER_2:$TARGET_PATH
fi


if [ $BACKUP_SERVER_3 ]; then
	# sync with remote server 3
	echo "*** SYNC WITH TARGET SERVER 3"
	echo $BACKUP_SERVER_3:$TARGET_PATH
	rsync -avrt --rsync-path="mkdir -p $TARGET_PATH && rsync -avrt" $FILEPATH $BACKUP_SERVER_3:$TARGET_PATH
fi


if [ $BUCKET_1 ]; then
	# sync with s3 storage server 1
	echo "*** SYNC WITH S3 STORAGE"
	echo s3://$BUCKET_1$TARGET_FOLDER
	s3cmd sync $FILEPATH s3://$BUCKET_1$TARGET_FOLDER
fi

echo "*** Mission Complete"
