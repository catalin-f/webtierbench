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
