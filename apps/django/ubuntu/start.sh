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
  mode=$(nodetool netstats | grep 'Mode')
  while [[$mode != *"NORMAL"*]]; do
        sleep 1
        mode=$(nodetool netstats | grep 'Mode')
  done
	cd django-workload/django-workload || exit 1

	source venv/bin/activate > /dev/null

	DJANGO_SETTINGS_MODULE=cluster_settings django-admin setup > /dev/null

	uwsgi uwsgi.ini &

	deactivate
}


### SET ENVIRONMENT ###
set_cpu_performance

(start_uwsgi)

