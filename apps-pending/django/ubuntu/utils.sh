#!/bin/bash

#######################################
# Starts a service
# Arguments:
#	  $1 = The service you want to start
# Additional information:
#	  None
#######################################
start_service() {
	echo "Starting $1 ..."
	service "$1" start
}

#######################################
# Stops a service
# Arguments:
#	  $1 = The service you want to stop
# Additional information:
#	  None
#######################################
stop_service() {
	echo "Stopping $1 ..."
	service "$1" stop
}

#######################################
# Waits for a port on localhost to become open
# Arguments:
#	  $1 = The port you want to wait for
#     $2 = Maximum number of seconds to wait
#	  $3 = Name of the monitored service
# Additional information:
#	  None
#######################################
wait_port() {
  delay=$2
  echo -n "Wait for $3 to start..."
  while ! netcat -w 1 localhost "$1" && [ $delay -gt 0 ]; do
    delay=$((delay - 1))
    sleep 1
   done

  if netcat -w 1 localhost "$1";
  then
     echo " done"
  else
     echo " failed, exiting"
     exit 1
  fi
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
		echo "$1 started"
	else
		echo "$1 couldn't be started. Benchmark run aborted"
		exit 1
	fi
}

#######################################
# Checks if the service was stopped succesfully
# Arguments:
#	  $1 = The name of the service to be checked
# Additional information:
#	  This method contains the exit call
#######################################
check_service_stopped() {
	if service $1 status > /dev/null;
	then
		echo "$1 couldn't be stopped. Benchmark run aborted"
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

usage() {
    echo "Usage sudo $0 $1"
    exit 7
}

set_cpu_performance() {
    for CPUFREQ in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
    do
        [ -f $CPUFREQ ] || continue
        echo -n performance > $CPUFREQ
    done
}
