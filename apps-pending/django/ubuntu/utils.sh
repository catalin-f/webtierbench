#!/bin/bash

#######################################
# Starts a service
# Arguments:
#	  $1 = The service you want to start
# Additional information:
#	  None
#######################################
start_service() {
	service $1 start
}

#######################################
# Starts a service
# Arguments:
#	  $1 = The service you want to stop
# Additional information:
#	  None
#######################################
stop_service() {
	service $1 stop
}

#######################################
# Checks if the service was started succesfully
# Arguments:
#	  $1 = The name of the service to be checked
# Additional information:
#	  This method contains the exit call
#######################################
check_service_started() {
	if service $1 status > /dev/null;
	then
		echo "$1 is up and running"
	else
		echo "$1 couldn't be started. Benchmark run aborted"
		exit 1
	fi
}

#######################################
# Checks if this script is run as root
# Arguments:
#	  None
# Additional information:
#	  This method contains the exit call
#######################################
check_root_privilege() {
	if [ "$(id -u)" != "0" ]; then
	   echo "This script must be run as root"
	   exit 1
	fi
}