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
press `ctrl+x` then press `y` to save file and exit

## get backup from all database
after above steps you can create a backup file from specefic database with command mysqldump without password

#### One specefic database
```mysqldump -v --column-statistics=0 YOUR_DATABASE_NAME > backup-$(date +%Y%m%d-%H%M%S).sql```

#### ALL database
it's depend on you to create a backup from one database or all.

```mysqldump -v --column-statistics=0 --all-databases > backup-$(date +%Y%m%d-%H%M%S).sql```

### Create sh file to do all steps
We are recommend to create backup from all. so create a sh file

```sudo nano auto-backup.sh```

copy and paste below line inside this sh. -v flag show process list and we don't need it inside automation process
```mysqldump --column-statistics=0 --all-databases > backup-$(date +%Y%m%d-%H%M%S).sql```



