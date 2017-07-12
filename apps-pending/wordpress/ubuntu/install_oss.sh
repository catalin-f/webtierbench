#!/bin/bash
set -x

if [ "$(id -u)" != "0" ]; then
	echo "This script must be run as root"
	exit 1
fi

oss_dir="$HOME/oss-performance"

apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0x5a16e7281be7a449
add-apt-repository "deb http://dl.hhvm.com/ubuntu xenial main"
http_proxy=http://$1 apt-get update

apt-get -y install nginx unzip mariadb-server util-linux coreutils autotools-dev autoconf \
	software-properties-common build-essential hhvm

cd $HOME
wget http://download.joedog.org/siege/siege-2.78.tar.gz
tar xzf siege-2.78.tar.gz
cd siege-2.78/
./configure
make
make install

cd $HOME
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

su $SUDO_USER -c "cd $HOME;					\
git clone https://github.com/hhvm/oss-performance;		\
cd $oss_dir;							\
wget https://getcomposer.org/installer -O composer-setup.php;	\
hhvm composer-setup.php;					\
hhvm composer.phar install"

service mysql start
systemctl stop nginx.service
systemctl disable nginx.service
