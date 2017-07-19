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
	killall uwsgi
}

#######################################
# Stops all siege processes
# Arguments:
#	None
# Additional information:
#	None
#######################################
stop_siege() {
	killall run-siege.sh
	killall siege
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
}

### MAIN CALL ###
main
