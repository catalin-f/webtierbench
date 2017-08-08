#!/bin/bash

### Invoke the utils script ###
. utils.sh

#######################################
# Stops all uwsgi processes
# Arguments:
#	None
# Additional information:
#	None
#######################################
stop_uwsgi() {
	echo "Stopping uwsgi ..."
	killall -q uwsgi
}

#######################################
# Stops all siege processes
# Arguments:
#	None
# Additional information:
#	None
#######################################
stop_siege() {
	echo "Stopping siege ..."
	killall -q run-siege
	killall -q siege
}

stop_benchmark() {
	echo "Stopping benchmark ..."
	killall -q start-benchmark.sh
}

#######################################
# This calls all methods described above
# Arguments:
#	None
# Additional information:
#	None
#######################################
main() {
	check_root_privilege
	stop_service "cassandra"
	check_service_stopped "cassandra"

	stop_service "memcached"
	check_service_stopped "memcached"

	stop_uwsgi
	stop_siege

	docker stop graphite
	stop_service "docker"

	stop_benchmark
}

### MAIN CALL ###
main
