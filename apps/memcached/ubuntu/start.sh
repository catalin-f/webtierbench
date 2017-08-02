#!/bin/bash

###############################################################################
# Environment data
WEBTIER_PATH=${WEBTIER_PATH}

###############################################################################

. ${WEBTIER_PATH}/apps/common_func.sh

###############################################################################
# Commands
###############################################################################

### SET ENVIRONMENT ###
set_cpu_performance

start_service "memcached"
check_service_started "memcached"
