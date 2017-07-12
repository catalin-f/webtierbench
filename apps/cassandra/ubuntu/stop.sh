#!/bin/bash

. ../../common_func.sh

. deploy.sh
#source ../common_func.sh
###############################################################################
# Environment data
###############################################################################


###############################################################################
# Commands
###############################################################################

#Stop data bese service
check_root_privilege
stop_service "cassandra"
check_service_stopped "cassandra"