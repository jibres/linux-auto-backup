#!/usr/bin/env bash

# create backup folder
mkdir -p LEMP
# copy nginx
cp -r /etc/nginx LEMP/
# copy php
cp -r /etc/php LEMP/
# copy MySQL
cp -r /etc/mysql LEMP/
# copy ssl
cp -r /etc/ssl LEMP/
# copy www folder
cp -r /var/www LEMP/
