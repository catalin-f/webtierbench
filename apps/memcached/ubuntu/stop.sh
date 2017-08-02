#!/bin/bash

###############################################################################
# Environment data
WEBTIER_PATH=${WEBTIER_PATH}

###############################################################################

. ${WEBTIER_PATH}/apps/common_func.sh

###############################################################################
# Commands
###############################################################################

#Stop memcached service and check if this service was stopped
stop_service "memcached"
check_service_stopped "memcached"