# Linux Auto Backup
Automatic backup from everything in your linux include MySQL, files and configs and transfer them to another server + s3 storage

You can follow these steps to take a backup from your database and transfer them to safe place outside of this server. then put it inside cronjob to do it periodically.
First login to your server, we are use Ubuntu.



## create a readonly user for backup
enter your mysql root password or some other user. change username if you want and enter your password
1. ```sudo mysql -u root -p```
2. ```CREATE USER 'dumper'@'localhost' IDENTIFIED WITH mysql_native_password BY 'PUT_YOUR_PASSWORD_HERE';```
3. ```GRANT SELECT, PROCESS, LOCK TABLES ON *.* TO 'dumper'@'localhost';```
4. ```flush privileges;```
5. ```exit;```


Also as alternative way, you can insert user via phpmyadmin. check only needed permission for create readonly user
![image](https://user-images.githubusercontent.com/8861284/111926849-1843f380-8acc-11eb-8245-183e3c5654ea.png)



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


## Setup S3 cmd
If you want to use s3 storage fro backup you need to install s3 cmd tools with below command

```apt-get install s3cmd```

After install, you need to config it with below command

```s3cmd --configure```

on config ask you below detail

1. Access Key
2. Secret Key
3. Default Region (press enter)
4. S3 Endpoint (give it from your s3 service something like fra1.digitaloceanspaces.com)
5. DNS-Style template (like previous)
6. Encryption password (press enter)
7. Path to GPG program (press enter)
8. use HTTPS (type `Yes` and press enter)
9. Http Proy server name (press enter)
10. Test access (type `Y` and press enter)
11. if Success, ask for save setting. type `y` and press enter


## Test sync command manually
on start before backup database, it's good idea to run sync process manually. on first run it was sync files already exist.

first you need to enter your config file for your server. fo to `conf` folder. create a copy from `conf/config.yaml` and rename it to your server name. it must seems like `config[MY_SERVER_NAME].me.yaml`.
open this file and edit. enable server backup or s3 storage.

after enter your config for this server run below command.

```bash sync-changes.sh```

then wait until transfer all exist files to backup server and s3 storage. on next step take we are add them into cronjob




## Setup cronjob
Setup a cronjob to sync your files automatically.

```crontab -e```

paste below line to run bash. first line run every one hour. second run every day on 3:30. third run every month on 4:30

```
0 * * * * root bash /home/linux-auto-backup/backup-hourly+sync.sh >/dev/null 2>&1
30 3 * * * root bash /home/linux-auto-backup/backup-daily.sh >/dev/null 2>&1
30 4 1 * * root bash /home/linux-auto-backup/backup-monthly.sh >/dev/null 2>&1
```

if on this server you don't have database and only need to backup from files you can set below cmd
```0 * * * * root bash /home/linux-auto-backup/sync-changes.sh >/dev/null 2>&1```

press `ctrl+x` then press `y` to save file and exit

