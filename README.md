# mysql-auto-backup
Automatic backup from all databases in MySQL and transfer them to another server

You can follow these steps to take a backup from your database and transfer them to safe place outside of this server. then put it inside cronjob to do it periodically.
First login to your server, we are use Ubuntu.

## create a readonly user for backup
1. Enter to mysql

```sudo mysql -u root -p```

2. enter your mysql root password or some other user. change username if you want and enter your password

```GRANT LOCK TABLES, SELECT ON *.* TO 'dumper'@'%' IDENTIFIED BY 'PUT_YOUR_PASSWORD_HERE';```

3. update privileges

```flush privileges;```

4. exit form MySQL

```Bye```
