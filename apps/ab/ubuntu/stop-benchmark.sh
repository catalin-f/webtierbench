#!/bin/bash

#######################################
# Checks if this script is run as root
# Arguments:
#   None
#	Additional information:
#		This method contains the exit call
#######################################
function check_root_privilege {
	if [ "$(id -u)" != "0" ]; then
	   echo "This script must be run as root"
	   exit 1
	fi
}

#######################################
# Stops the cassandra service
# Arguments:
#		None
#	Additional information:
#		None
#######################################
function stop_cassandra {
	sudo service cassandra stop
}

#######################################
# Checks the status of the cassandra service
# Arguments:
#		None
#	Additional information:
#		None
#######################################
function check_cassandra_status {
	sudo service cassandra status > /dev/null

	if [ $? -eq 0 ];
	then
		echo "Cassandra couldn't be stopped."
		exit 1
	fi
}

#######################################
# Stops the memcached service
# Arguments:
#		None
#	Additional information:
#		None
#######################################
function stop_memcached {
	sudo service memcached stop
}

#######################################
# Checks the status of the memcached service
# Arguments:
#		None
#	Additional information:
#		None
#######################################
function check_memcached_status {
	sudo service memcached status > /dev/null

	if [ $? -eq 0 ];
	then
		echo "Memcached couldn't be stopped."
		exit 1
	fi
}

#######################################
# Stops all uwsgi processes
# Arguments:
#		None
#	Additional information:
#		None
#######################################
function stop_uwsgi {
	sudo killall uwsgi
}

#######################################
# Stops all siege processes
# Arguments:
#		None
#	Additional information:
#		None
#######################################
function stop_siege {
	sudo killall run-siege.sh
	sudo killall siege
}

#######################################
# This calls all methods described above
# Arguments:
#		None
#	Additional information:
#		None
#######################################
function main {
	check_root_privilege
	stop_cassandra
	check_cassandra_status

	stop_memcached
	check_memcached_status

	stop_uwsgi
	stop_siege
}

### MAIN CALL ###
main
