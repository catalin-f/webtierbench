#!/bin/bash

###############################################################################
# Environment data
WEBTIER_SIEGE_WORKERS=${WEBTIER_SIEGE_WORKERS}
WEBTIER_SIEGE_RUNMODE=${WEBTIER_SIEGE_RUNMODE}
WEBTIER_PATH=${WEBTIER_PATH}

###############################################################################

. ${WEBTIER_PATH}/apps/common_func.sh

###############################################################################
# Commands
###############################################################################

#######################################
# Runs siege <no_attempts> times
# Arguments:
#	$1 = The number of attempts
# Additional information:
#	This method contains the exit call
#######################################
run_siege() {

	pip3 install numpy
	cd django-workload/client || exit 1

	if [ -n "${WEBTIER_SIEGE_RUNMODE}" ]; then

	    for (( i=1; i<=$1; i++ ))
	    do
	        printf "\n### SIEGE RUN %d OUT OF %d ###\n\n" "$i" "$1"

	        su $SUDO_USER -c "LOG=/home/$SUDO_USER/siege.log ./run-siege --single"
	    done
	    #pip3 uninstall numpy
	else
	    su $SUDO_USER -c "LOG=/home/$SUDO_USER/siege.log ./run-siege"
	fi
}

### SET ENVIRONMENT ###
set_cpu_performance
(run_siege ${WEBTIER_SIEGE_WORKERS})
