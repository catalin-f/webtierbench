#!/bin/sh

oss_dir=~/oss-performance

sudo apt-get -y install nginx unzip mysql-server util-linux coreutils
sudo apt-get -y install autotools-dev
sudo apt-get -y install autoconf
sudo apt-get -y install software-properties-common build-essential
sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0x5a16e7281be7a449
sudo add-apt-repository "deb http://dl.hhvm.com/ubuntu xenial main"
sudo apt-get update
sudo apt-get -y install hhvm
sudo apt-get -y install php7.0 php7.0-cgi php7.0-fpm
sudo apt-get -y install php7.0-mysql php7.0-curl php7.0-gd php7.0-intl php-pear php-imagick php7.0-imap php7.0-mcrypt php-memcache  php7.0-pspell php7.0-recode php7.0-sqlite3 php7.0-tidy php7.0-xmlrpc php7.0-xsl php7.0-mbstring php-gettext
sudo apt-get install siege

cd ~
echo '************************************************************'
echo 'Checking if oss-performance is already installed:'
if [ -d "$oss_dir" ]; then
	rm -rf "$oss_dir"
	echo ' - oss-performance was found and removed'
	echo '************************************************************'
else
	echo ' - oss-performance was not found'
	echo '************************************************************'
fi
git clone https://github.com/hhvm/oss-performance
cd "$oss_dir"

wget https://getcomposer.org/installer -O composer-setup.php
pwd
php composer-setup.php
php composer.phar install
