#!/bin/bash

#######################################
# Checks the type of the supplied parameter and also it's value
# Arguments:
# 	$1 = the parameter to be checked
# Additional information:
#	This method contains the exit call
#######################################
function check_parameter_validity {
	re='^[0-9]+$'

	if ! [[ $1 =~ $re ]] ; then
	   echo "The first parameter must be a number"
	   exit 1
	fi

	if (("$1" == 0)); then
	   echo "The first parameter cannot be 0"
	   exit 1
	fi
}

#######################################
# Checks if this script is run as root
# Arguments:
#	None
# Additional information:
#	This method contains the exit call
#######################################
function check_root_privilege {
	if [ "$(id -u)" != "0" ]; then
	   echo "This script must be run as root"
	   exit 1
	fi
}

#######################################
# Checks the number of parameters supplied to the script
# Arguments:
#	$1 = the number of supplied parameters
# Additional information:
#	This method contains the exit call
#######################################
function check_script_usage {
	if [ "$1" -ne 1 ]; then
	    echo "Usage: ./run-benchmark <number_of_attempts>"
	    exit 1
	fi
}

#######################################
# Sets the CPU FREQUENCY to no scaling in order to obtain accurate measurements
# Arguments:
#	None
# Additional information:
#	None
#######################################
function set_cpu_performance {
	for CPUFREQ in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
	do
	    [ -f $CPUFREQ ] || continue
	    echo -n performance > $CPUFREQ
	done
}

#######################################
# Starts the associated Cassandra service
# Arguments:
#	None
# Additional information:
#	None
#######################################
function start_cassandra {
	 service cassandra start
}

#######################################
# Checks if the Cassandra service is up and running
# Arguments:
#  	None
# Additional information:
#	This method contains the exit call
#######################################
function check_cassandra_status {
	service cassandra status > /dev/null

	if [ $? -eq 0 ];
	then
		echo "Cassandra is up and running"
	else
		echo "Cassandra couldn't be started. Benchmark run aborted"
		exit 1
	fi
}

#######################################
# Starts the associated memcached service
# Arguments:
#	None
# Additional information:
#	None
#######################################
function start_memcached {
	service memcached start
}

#######################################
# Checks if the memcached service is up and running
# Arguments:
# 	None
# Additional information:
#	This method contains the exit call
#######################################
function check_memcached_status {
	service memcached status > /dev/null

	if [ $? -eq 0 ];
	then
		echo "Memcached is up and running"
	else
		echo "Memcached couldn't be started. Benchmark run aborted"
		exit 1
	fi
}

#######################################
# Starts graphite container (docker needs to be up and running)
# Arguments:
#	None
# Additional information:
#	None
#######################################
function start_graphite {
	docker start graphite > /dev/null
}

#######################################
# Checks if graphite is up and running
# Arguments:
#	None
# Additional information:
#	This method contains the exit call
#######################################
function check_graphite_status {
	docker ps --filter "name=graphite" | grep Up > /dev/null

	if [ $? -eq 0 ];
	then
		echo "Graphite is up and running"
	else
		echo "Graphite couldn't be started. Benchmark run aborted"
		exit 1
	fi
}

#######################################
# Starts uwsgi in background
# Arguments:
#	None
# Additional information:
#	This method uses the virtual environment to start the uwsgi
#######################################
function start_uwsgi {
	cd django-workload
	rm -rf vend

	python3 -m virtualenv -p python3 venv > /dev/null
	source venv/bin/activate > /dev/null

	DJANGO_SETTINGS_MODULE=cluster_settings django-admin setup > /dev/null

	uwsgi uwsgi.ini &

	deactivate
}

#######################################
# Runs siege <no_attempts> times
# Arguments:
#	$1 = The number of attempts
# Additional information:
#	None
#######################################
function run_siege {
	cd ../client

	for (( i=1; i<=$1; i++ ))
	do
	   printf "\n### SIEGE RUN COUNT = %d ###\n\n" "$i"

		 ./run-siege.sh
	done
}

#######################################
# Executes all the methods described above
# Arguments:
#	$1 = the number of paramters supplied to the script
#  	$2 = the first parameter
# Additional information:
#	 None
#######################################

function main {

	### CHECKS ###
	check_root_privilege
	check_script_usage $1
	check_parameter_validity $2

	### SET ENVIRONMENT ###
	set_cpu_performance

	start_cassandra
	check_cassandra_status

	sleep 3 # THIS WAITS FOR CASSANDRA TO LOAD COMPLETELY [CHANGE IT ACCORDING TO THE CPU]

	start_memcached
	check_memcached_status

	start_graphite
	check_graphite_status

	start_uwsgi

	### RUN THE BENCHMARK ###
	run_siege $2

	./stop-benchmark.sh
}

### MAIN CALL ###
main $# $1
