#!/usr/bin/env bash
cd "$(dirname "${BASH_SOURCE[0]}")"
# create backup folder
mkdir -p LEMP

# copy nginx
if [ -d "/etc/nginx/" ] 
then
	rsync -at --no-links /etc/nginx LEMP/ | grep -v "skipping non-regular file"
fi

# copy php
if [ -d "/etc/php/" ] 
then
	rsync -at --no-links /etc/php LEMP/ | grep -v "skipping non-regular file"
fi

# copy MySQL
if [ -d "/etc/mysql/" ] 
then
	rsync -at --no-links /etc/mysql LEMP/ | grep -v "skipping non-regular file"
fi

# copy ssl
if [ -d "/etc/ssl/" ] 
then
	rsync -at --no-links /etc/ssl LEMP/ | grep -v "skipping non-regular file"
fi

# copy www folder
if [ -d "/etc/www/" ] 
then
	rsync -at --no-links /var/www LEMP/ | grep -v "skipping non-regular file"
fi