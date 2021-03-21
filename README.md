# mysql-auto-backup
Automatic backup from all databases in MySQL and transfer them to another server

You can follow these steps to take a backup from your database and transfer them to safe place outside of this server. then put it inside cronjob to do it periodically.
First login to your server, we are use Ubuntu.

## create a readonly user for backup
1. Enter to mysql

```sudo mysql -u root -p```

2. enter your mysql root password or some other user. change username if you want and enter your password

```CREATE USER 'dumper'@'localhost' IDENTIFIED WITH mysql_native_password BY 'PUT_YOUR_PASSWORD_HERE';```
```GRANT SELECT, LOCK TABLES ON *.* TO 'dumper'@'localhost';```

3. update privileges

```flush privileges;```

4. exit form MySQL

```exit;```


Also as alternative way, you can inser user via phpmyadmin. check only needed permission for create readonly user
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

## create sh to get backup from all database


