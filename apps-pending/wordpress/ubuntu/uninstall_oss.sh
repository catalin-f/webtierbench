#!/bin/sh

oss_dir="$HOME/oss-performance"

apt-get purge -y siege nginx mysql-server hhvm

cd $HOME

rm -rf siege-2.78/
rm -rf siege-2.78.tar.gz

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

apt-get autoremove
apt-get update
