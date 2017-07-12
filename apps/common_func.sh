#!/bin/bash
###############################################################################
# Environment data
###############################################################################

###############################################################################
# Commands
##############################################################################


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

#######################################
# Checks if the proxy parameter is correctly supplied
# Arguments:
#	  $1 = The proxy in the format of <ip_address>:<port>
# Additional information:
#	  None
#######################################
check_proxy_parameter() {
	if [[ $1 =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:[0-9]+$ ]]; then
  	return 0
	else
  	return 1
	fi
}

#######################################
# Configures the general proxy settings
# Arguments:
#	  $1 = The proxy in the format of <ip_address>:<port>
# Additional information:
#	  None
#######################################
set_general_proxy_configuration() {

	# Set Docker proxy
	mkdir -p /etc/systemd/system/docker.service.d
	echo "[Service]" >> /etc/systemd/system/docker.service.d/http-proxy.conf
	echo "Environment='HTTP_PROXY=http://$1'">> /etc/systemd/system/docker.service.d/http-proxy.conf

  # Set git configuration to pull through proxy
	git config --global http.proxy http://$1
}

#######################################
# Sets the CPU FREQUENCY to no scaling in order to obtain accurate measurements
# Arguments:
#	None
# Additional information:
#	None
#######################################
set_cpu_performance() {
	for CPUFREQ in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
	do
	    [ -f $CPUFREQ ] || continue
	    echo -n performance > $CPUFREQ
	done
}

#######################################
# Debug function
#Argumets:
#   debug message
# Additional information:
#	None
#######################################

debug(){
    echo -e $1
}