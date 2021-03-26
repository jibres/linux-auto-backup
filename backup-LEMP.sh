#!/usr/bin/env bash

# create backup folder
mkdir -p LEMP
# copy nginx
rsync -at --no-links /etc/nginx LEMP/ | grep -v "skipping non-regular file"
# copy php
rsync -at --no-links /etc/php LEMP/ | grep -v "skipping non-regular file"
# copy MySQL
rsync -at --no-links /etc/mysql LEMP/ | grep -v "skipping non-regular file"
# copy ssl
rsync -at --no-links /etc/ssl LEMP/ | grep -v "skipping non-regular file"
# copy www folder
rsync -at --no-links /var/www LEMP/ | grep -v "skipping non-regular file"
