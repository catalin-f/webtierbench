#!/bin/bash

###############################################################################
# Environment data
###############################################################################
WEBTIER_PATH=${WEBTIER_PATH}
WEBTIER_WORKERS=${WEBTIER_WORKERS}

###############################################################################
# Commands
###############################################################################
. ${WEBTIER_PATH}/apps/common_func.sh


oss_dir="${WEBTIER_PATH}/oss-performance"

service mysql start
systemctl restart nginx.service
set_cpu_performance

echo 1 | sudo tee /proc/sys/net/ipv4/tcp_tw_reuse
chmod -R 775 /var/log/nginx

for (( i=1; i<=${WEBTIER_WORKERS}; i++ ))
do
	su $SUDO_USER -c "echo '****************************************************';	\
	echo '*                  Test Run No $i                   *';			\
	echo '****************************************************';			\
	cd $oss_dir; 									\
	/usr/bin/hhvm perf.php --wordpress --hhvm=/usr/bin/hhvm"
done

systemctl stop nginx.service