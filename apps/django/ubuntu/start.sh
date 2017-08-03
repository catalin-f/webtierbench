#!/bin/bash

###############################################################################
# Environment data
WEBTIER_PATH=${WEBTIER_PATH}

CASSANDRA_IP=${CASSANDRA_IP}
MEMCACHED_IP=${MEMCACHED_IP}
SIEGE_IP=${SIEGE_IP}
LOCALHOST_IP=${LOCALHOST_IP}
GRAPHITE_IP=${GRAPHITE_IP}
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

  sed -e "s/DATABASES\['default'\]\['HOST'\] = 'localhost'/DATABASES\['default'\]\['HOST'\] = '$CASSANDRA_IP'/g"                                    \
        -e "s/CACHES\['default'\]\['LOCATION'\] = '127.0.0.1:11811'/CACHES\['default'\]\['LOCATION'\] = '$MEMCACHED_IP'/g"                          \
        -e "s/ALLOWED_HOSTS = \[/ALLOWED_HOSTS = \['$CASSANDRA_IP', '$MEMCACHED_IP', '$SIEGE_IP', '$GRAPHITE_IP', '$LOCALHOST_IP', /g" \
        -e "s/STATSD_HOST = 'localhost'/STATSD_HOST = '$GRAPHITE_IP'/g"                                                                             \
        -e "s/PROFILING = False/PROFILING = True/g"                                                                                                 \
        -i cluster_settings.py

  sed -i "s/processes = 88/processes = $(grep -c processor /proc/cpuinfo)/g" uwsgi.ini

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
