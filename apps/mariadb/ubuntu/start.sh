#!/bin/bash

###############################################################################
# Environment data
###############################################################################
WEBTIER_PATH=${WEBTIER_PATH}

###############################################################################
# Commands
###############################################################################
. ${WEBTIER_PATH}/apps/common_func.sh


### SET ENVIRONMENT ###
set_cpu_performance

start_service "mysql"
check_service_started "mysql"
mysql -u root -e "USE mysql; UPDATE user SET plugin='mysql_native_password' WHERE User='root'; FLUSH PRIVILEGES;"
