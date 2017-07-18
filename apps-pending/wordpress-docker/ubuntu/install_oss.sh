#!/bin/bash
set -x

oss_dir="/home/hhvmuser/oss-performance"

#echo '*********************** Install Git ************************'
#cd /home
#apt-get install libssl-dev libcurl4-gnutls-dev libexpat1-dev gettext
#wget https://github.com/git/git/archive/master.zip -O git.zip
#unzip git.zip
#cd git-*
#make prefix=/usr/local all
#make prefix=/usr/local install

cd /home/hhvmuser
git clone https://github.com/hhvm/oss-performance
cd $oss_dir
wget https://getcomposer.org/installer -O composer-setup.php
hhvm composer-setup.php
hhvm composer.phar install
