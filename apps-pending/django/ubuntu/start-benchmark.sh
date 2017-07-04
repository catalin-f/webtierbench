#!/bin/bash

### Invoke the utils script ###
source utils.sh

#######################################
# Checks the type of the supplied parameter and also it's value
# Arguments:
# 	$1 = the parameter to be checked
# Additional information:
#	This method contains the exit call
#######################################
check_parameter_validity() {
	re='^[1-9]+$'

	if ! [[ $1 =~ $re ]] ; then
	   echo "The first parameter must be a non zero number"
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
check_script_usage() {
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
set_cpu_performance() {
	for CPUFREQ in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
	do
	    [ -f $CPUFREQ ] || continue
	    echo -n performance > $CPUFREQ
	done
}

#######################################
# Starts uwsgi in background
# Arguments:
#	None
# Additional information:
#	This method uses the virtual environment to start the uwsgi
#######################################
start_uwsgi() {
	cd django-workload || exit 1

	source venv/bin/activate > /dev/null

	DJANGO_SETTINGS_MODULE=cluster_settings django-admin setup > /dev/null

	uwsgi uwsgi.ini &

	deactivate
}

#######################################
# Checks if graphite has started succesfully
# Arguments:
#		None
# Additional information:
#		None
#######################################
check_graphite_status() {
	 if docker inspect -f {{.State.Running}} graphite > /dev/null; then
	 		echo "Graphite is up and running"
	 fi
}

#######################################
# Runs siege <no_attempts> times
# Arguments:
#	$1 = The number of attempts
# Additional information:
#	This method contains the exit call
#######################################
run_siege() {
	cd ../client || exit 1

	for (( i=1; i<=$1; i++ ))
	do
	   printf "\n### SIEGE RUN %d OUT OF %d ###\n\n" "$i" "$1"

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

main() {

	### CHECKS ###
	check_root_privilege
	check_script_usage $1
	check_parameter_validity $2

	### SET ENVIRONMENT ###
	set_cpu_performance

	start_service "cassandra"
	check_service_started "cassandra"

	sleep 3 # THIS WAITS FOR CASSANDRA TO LOAD COMPLETELY [CHANGE IT ACCORDING TO THE CPU]

	start_service "memcached"
	check_service_started "memcached"

	start_service "docker"
	check_service_started "docker"
	check_graphite_status

	start_uwsgi

	### RUN THE BENCHMARK ###
	run_siege $2

	./stop-benchmark.sh
}

### MAIN CALL ###
main $# $1
