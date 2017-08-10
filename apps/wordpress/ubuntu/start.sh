#!/bin/bash

###############################################################################
# Environment data
###############################################################################
WEBTIER_PATH=${WEBTIER_PATH}
WEBTIER_WORDPRESS_WORKERS=${WEBTIER_WORDPRESS_WORKERS}
WEBTIER_DB_USER=${WEBTIER_DB_USER}
WEBTIER_DB_PWD=${WEBTIER_DB_PWD}
WEBTIER_OSS_RUNNIG_MODE=${WEBTIER_OSS_RUNNIG_MODE}

###############################################################################
# Commands
###############################################################################
. ${WEBTIER_PATH}/apps/common_func.sh


oss_dir="${WEBTIER_PATH}/oss-performance"

if [ -f ${HOME}/siege.log ]; then
    rm ${HOME}/siege.log
fi

systemctl restart nginx.service
set_cpu_performance

echo 1 | sudo tee /proc/sys/net/ipv4/tcp_tw_reuse
chmod -R 775 /var/log/nginx

for (( i=1; i<=${WEBTIER_WORDPRESS_WORKERS}; i++ ))
do
	su $SUDO_USER -c "cd $oss_dir; 									\
	/usr/bin/hhvm perf.php --wordpress --hhvm=/usr/bin/hhvm --db-username ${WEBTIER_DB_USER} --db-password $WEBTIER_DB_PWD ${WEBTIER_OSS_RUNNIG_MODE}"
done

systemctl stop nginx.service