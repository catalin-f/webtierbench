#!/bin/bash

. ../../common_func.sh
###############################################################################
# Environment data
###############################################################################


###############################################################################
# Commands
###############################################################################

#Stop memcached service and check if this service was stopped
check_root_privilege
stop_service "memcached"
check_service_stopped "memcached"