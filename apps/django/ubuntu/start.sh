#!/bin/bash

###############################################################################
# Environment data
WEBTIER_PATH=${WEBTIER_PATH}
###############################################################################

. ${WEBTIER_PATH}/apps/common_func.sh

###############################################################################
# Commands
###############################################################################

#######################################
# Starts uwsgi in background
# Arguments:
#	None
# Additional information:
#	This method uses the virtual environment to start the uwsgi
#######################################
start_uwsgi() {
	cd django-workload/django-workload || exit 1

	source venv/bin/activate > /dev/null:q

	DJANGO_SETTINGS_MODULE=cluster_settings django-admin setup > /dev/null

	uwsgi uwsgi.ini &

	deactivate
}


### SET ENVIRONMENT ###
set_cpu_performance

start_uwsgi

