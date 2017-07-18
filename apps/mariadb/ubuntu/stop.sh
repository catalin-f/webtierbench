#!/bin/bash

. ../../common_func.sh

###############################################################################
# Environment data
###############################################################################
WEBTIER_HTTP_PROXY=${WEBTIER_HTTP_PROXY}


###############################################################################
# Commands
###############################################################################

#Stop data bese service
check_root_privilege
stop_service "mysql"
check_service_stopped "mysql"