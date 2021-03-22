# Simple bash script to backup sql database into file with mysqldump and transfer it to another server

#define server name
ZONE=`hostname`
#ZONE=YOUR_SERVER_NAME

#define file name
FILENAME=backup[$ZONE]alldb-$(date +%H).sql.gz

#define folder name
BACKUP_FOLDER="hourly"

#define file path
FOLDER_PATH="$(pwd)/$BACKUP_FOLDER"
# create folder if not exist
mkdir -p $FOLDER_PATH
# create file full path
FILEPATH=$FOLDER_PATH/$FILENAME

#define remote server addr
TARGET=root@1.2.3.4

#define remote server path
TARGET_FOLDER=/mysql-auto-backup/$ZONE/$BACKUP_FOLDER/
TARGET_PATH=/home$TARGET_FOLDER




# create a dump from all database
echo "*** START DUMP DATABASE"
#mysqldump --quick --single-transaction --column-statistics=0 --all-databases | gzip > $FILEPATH

# sync with remote server
echo "*** SYNC WITH TARGET SERVER"
rsync -avrt --rsync-path="mkdir -p $TARGET_PATH && rsync" $FILEPATH $TARGET:$TARGET_PATH

echo "*** SYNC WITH S3 STORAGE"
s3cmd sync $FILEPATH s3://talambar$TARGET_FOLDER

echo "*** Mission Complete"
