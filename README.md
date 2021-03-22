# mysql-auto-backup
Automatic backup from all databases in MySQL and transfer them to another server

You can follow these steps to take a backup from your database and transfer them to safe place outside of this server. then put it inside cronjob to do it periodically.
First login to your server, we are use Ubuntu.



## create a readonly user for backup
enter your mysql root password or some other user. change username if you want and enter your password
1. ```sudo mysql -u root -p```
2. ```CREATE USER 'dumper'@'localhost' IDENTIFIED WITH mysql_native_password BY 'PUT_YOUR_PASSWORD_HERE';```
3. ```GRANT SELECT, LOCK TABLES ON *.* TO 'dumper'@'localhost';```
4. ```flush privileges;```
5. ```exit;```


Also as alternative way, you can insert user via phpmyadmin. check only needed permission for create readonly user
![image](https://user-images.githubusercontent.com/8861284/111922973-79fb6200-8aba-11eb-98cb-d9fd7674b29a.png)



## save user and password of dump user for mysql
open or create mysql public conf file

```sudo nano ~/.my.cnf```

copy and paste below text and update username and password if needed

```
[mysqldump]
user=dumper
password=PUT_YOUR_PASSWORD_HERE
```
Press `ctrl+x` then press `y` to save file and exit

## get backup from database
after above steps you can create a backup file from specefic database with command mysqldump without password. -v flag show process list and we don't need it inside automation process

#### One specefic database
```mysqldump -v --column-statistics=0 YOUR_DATABASE_NAME > /home/backup-$(date +%Y%m%d-%H%M%S).sql```

#### ALL database
it's depend on you to create a backup from one database or all.

```mysqldump -v --column-statistics=0 --all-databases > backup-$(date +%Y%m%d-%H%M%S).sql```



## Setup File Mirroring Using Rsync
To sync your files from server A (main) to server B (backup), follow these steps.

### install rsync
Install rsync on both server A and server B.

```apt-get install rsync```

### Generate an SSH key
Run the following command to generate an SSH key.

```ssh-keygen```

Press enter to skip all inputs.

### Save auto login to target server

```ssh-copy-id root@1.2.3.4```

press yes and enter password of target server. you can change user to anything

### rsync syntax example
Connect on port 22 of ssh. delete file on target server if exist then copy to path in another server
```rsync -avrt --delete --rsh='ssh -p 22' /home/backup-file.sql /target_server/path/```



## Create sh file to do all steps
We are recommend to create backup from all. so create a sh file

```sudo nano /home/mysql-auto-backup/backup.sh```

Copy and paste below line inside editor to create mysql backup

```mysqldump --column-statistics=0 --all-databases > /home/mysql-auto-backup/backup-all.sql```

then we need to transfer this file to another location, so use rsync

```rsync -avrt --delete /home/mysql-auto-backup/backup-all.sql root@1.2.3.4:/home/mysql-auto-backup/```

press `ctrl+x` then press `y` to save file and exit



## Setup cronjob
Setup a cronjob to sync your files automatically. This example syncs them every 10 minutes.

```nano /etc/crontab```

paste below line to run sh

```*/10 * * * * root sh /home/mysql-auto-backup/ >/dev/null 2>&1```

press `ctrl+x` then press `y` to save file and exit

