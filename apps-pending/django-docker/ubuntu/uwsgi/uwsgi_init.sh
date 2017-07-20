#!/bin/bash

# This script will be executed each time the uWSGI container is run.
# It is called with a single parameter ($1) - the container hostname (uwsgi)

echo "Starting uWSGI init script on container..."

HOSTNAME=$1

# Go on the working directory
cd /django-workload/django-workload || exit 1

# Update the cluster_settings with the appropriate settings (passed through environment variables)
sed -i "s/DATABASES\['default'\]\['HOST'\] = 'localhost'/DATABASES\['default'\]\['HOST'\] = '$CASSANDRA_ENDPOINT'/g" cluster_settings.py
sed -i "s/CACHES\['default'\]\['LOCATION'\] = '127.0.0.1:11811'/CACHES\['default'\]\['LOCATION'\] = '$MEMCACHED_ENDPOINT'/g" cluster_settings.py
sed -i "s/ALLOWED_HOSTS = \[/ALLOWED_HOSTS = \['$CASSANDRA_ENDPOINT','$MEMCACHED_ENDPOINT','$HOSTNAME',/g" cluster_settings.py

# Activate the virtual environment
. venv/bin/activate

# Set the django settings
DJANGO_SETTINGS_MODULE=cluster_settings django-admin setup > /dev/null

# Start uwsgi process
uwsgi uwsgi.ini &

deactivate

# Keep the uwsgi process running
tail -f /dev/null
