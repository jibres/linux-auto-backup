# Simple bash script to backup sql database into file with mysqldump and transfer it to another server

#define server name
ZONE=$HOSTNAME
#ZONE=YOUR_SERVER_NAME

#define file name
FILENAME=backup-$ZONE-db-$(date +%H).sql.gz

#define folder name
BACKUP_FOLDER=hourly

#define file path
FILEPATH=$BACKUP_FOLDER/$FILENAME

#define remote server addr
TARGET=root@1.2.3.4

TARGET_PATH=$ZONE/mysql-auto-backup/$BACKUP_FOLDER

# create a dump from all database
mysqldump --quick --single-transaction --column-statistics=0 --all-databases | gzip > $FILEPATH

# sync with remote server
rsync -avrt $FILEPATH $TARGET:/home/$TARGET_PATH/

#sync with s3 compatible storage
s3cmd sync $BACKUP_FOLDER/ s3://YOUR_BUCKET/$TARGET_PATH/
