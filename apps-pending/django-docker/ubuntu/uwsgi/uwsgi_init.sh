#!/bin/bash

################################### Description ########################################
#
# This script will be called when the uWSGI container is run (powered on / executed).
# When we run the uWSGI container, we need to pass the cassandra and memcached ip's and ports.
# We will do this passing using environment variables that we set when the docker run command is run
# and we read them in this script.
# For example, consider following command:
#
#   docker run -e CASSANDRA_ENDPOINT='192.168.1.2:2211' -e MEMCACHED_ENDPOINT='192.168.1.2:2211' uwsgi-webtier
#
# In this script, we will have access to the CASSANDRA_ENDPOINT and MEMCACHED_ENDPOINT variables.
#
########################################################################################

#### This script is currently under development ####

echo "Starting uWSGI init script on container..."

# Go on the working directory
cd /django-workload/django-workload || exit 1

# Update the cluster_settings with the appropriate settings (passed through environment variables)
sed -i "s/DATABASES\['default'\]\['HOST'\] = 'localhost'/DATABASES\['default'\]\['HOST'\] = '$CASSANDRA_ENDPOINT'/g" cluster_settings.py
sed -i "s/CACHES\['default'\]\['LOCATION'\] = '127.0.0.1:11811'/CACHES\['default'\]\['LOCATION'\] = '$MEMCACHED_ENDPOINT'/g" cluster_settings.py

# Activate the virtual environment
. venv/bin/activate

# Set the django settings
DJANGO_SETTINGS_MODULE=cluster_settings django-admin setup > /dev/null

# Start uwsgi process
uwsgi uwsgi.ini &

deactivate

# Keep the uwsgi process running
tail -f /dev/null
