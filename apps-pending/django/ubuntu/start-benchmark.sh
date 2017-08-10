#!/bin/bash

### Invoke the utils script ###
. utils.sh

#######################################
# Starts uwsgi in background
# Arguments:
#	None
# Additional information:
#	This method uses the virtual environment to start the uwsgi
#######################################
start_uwsgi() {
	cd django-workload/django-workload || exit 1

	. venv/bin/activate > /dev/null

	uwsgi uwsgi.ini &

	deactivate
}

#######################################
# Checks if graphite has started succesfully
# Arguments:
#	None
# Additional information:
#	None
#######################################
check_graphite_status() {
	 if docker inspect -f {{.State.Running}} graphite > /dev/null; then
	 	echo "Graphite is up and running"
	 fi
}

#######################################
# Runs siege <no_attempts> times
# Arguments:
#	None
# Additional information:
#	This method contains the exit call
#######################################
run_siege() {
	cd django-workload/client || exit 1

	printf "\n### SIEGE RUN ###\n\n"

	su "$SUDO_USER" -c "LOG=/tmp/siege.log ./run-siege"
}

#######################################
# Executes all the methods described above
# Arguments:
#	$1 = the number of parameters supplied to the script
#  	$2 = the first parameter
# Additional information:
#	 None
#######################################

main() {

	### CHECKS ###
	check_root_privilege

	# Remove old logs
	rm -rf /tmp/siege*

	### SET ENVIRONMENT ###
	set_cpu_performance

	start_service "cassandra"
	check_service_started "cassandra"

	#wait for cassandra a max of 3 minutes
	wait_port 9042 1800 "cassandra"

	start_service "memcached"
	check_service_started "memcached"

	start_service "docker"
	check_service_started "docker"

	docker start graphite
	check_graphite_status

	(start_uwsgi)

	#wait for uwsgi a max of 3 minutes
	wait_port 8000 1800 "uwsgi"

	### RUN THE BENCHMARK ###
	(run_siege)

	trap 'mv -f /tmp/siege* ../../data_store/tmp; exit' 0 2 15
}

### MAIN CALL ###
main $# $1
