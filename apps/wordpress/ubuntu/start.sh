#!/bin/bash

###############################################################################
# Environment data
###############################################################################
WEBTIER_PATH=${WEBTIER_PATH}
WEBTIER_WORDPRESS_WORKERS=${WEBTIER_WORDPRESS_WORKERS}

###############################################################################
# Commands
###############################################################################
. ${WEBTIER_PATH}/apps/common_func.sh


oss_dir="${WEBTIER_PATH}/oss-performance"

systemctl restart nginx.service
set_cpu_performance

echo 1 | sudo tee /proc/sys/net/ipv4/tcp_tw_reuse
chmod -R 775 /var/log/nginx

for (( i=1; i<=${WEBTIER_WORDPRESS_WORKERS}; i++ ))
do
	su $SUDO_USER -c "LOG=/home/$SUDO_USER/siege.log \
	cd $oss_dir; 									\
	/usr/bin/hhvm perf.php --wordpress --hhvm=/usr/bin/hhvm --db-username root --db-password '' > ~/siege1.log"
done

systemctl stop nginx.service