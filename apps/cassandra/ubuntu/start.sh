#!/bin/bash

. ../../common_func.sh

###############################################################################
# Environment data
###############################################################################


###############################################################################
# Commands
###############################################################################

### SET ENVIRONMENT ###
set_cpu_performance

start_service "cassandra"
check_service_started "cassandra"

sleep 5 # THIS WAITS FOR CASSANDRA TO LOAD COMPLETELY [CHANGE IT ACCORDING TO THE CPU]