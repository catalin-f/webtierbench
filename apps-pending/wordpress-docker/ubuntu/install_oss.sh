#!/bin/bash

oss_dir="/home/hhvmuser/oss-performance"

cd /home/hhvmuser
git clone --progress https://github.com/hhvm/oss-performance
cd /home/hhvmuser/oss-performance
wget https://getcomposer.org/installer -O composer-setup.php
hhvm composer-setup.php
hhvm composer.phar install
