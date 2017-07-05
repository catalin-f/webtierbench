#!/bin/sh

oss_dir=~/oss-performance

sudo apt-get remove siege
sudo apt-get remove nginx
sudo apt-get remove mysql-server
sudo apt-get remove hhvm
sudo apt-get remove php7.0-mysql php7.0-curl php7.0-gd php7.0-intl php-pear php-imagick php7.0-imap php7.0-mcrypt php-memcache  php7.0-pspell php7.0-recode php7.0-sqlite3 php7.0-tidy php7.0-xmlrpc php7.0-xsl php7.0-mbstring php-gettext

cd ~
if [ -d "$oss_dir" ]; then
	rm -rf "$oss_dir"
	echo '************************************************************'
	echo 'oss-performance successfully removed'
	echo '************************************************************'
else
	echo '************************************************************'
	echo 'oss-performance directory was not found'
	echo '************************************************************'
fi

sudo apt-get purge
sudo apt-get update
