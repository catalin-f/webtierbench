#!/bin/bash

################################### Description ########################################
#
# This script will start a docker container for each service necessary in the django workload
# It is created only for demonstration purposes, to see how we should power on a docker container.
# In a production environment, we'll use a tool that will manage our containers automatically.
#
########################################################################################


# Start memcached container
docker run rintech/webtierbench:memcache-webtier

# Start cassandra container
docker run rintech/webtierbench:cassandra-webtier

# Start uwsgi container
docker run -e CASSANDRA_ENDPOINT='<ip>:<port>' -e MEMCACHED_ENDPOINT='<ip>:<port>' rintech/webtierbench:uwsgi-webtier

# Start siege container
docker run -e ATTEMPTS='<no_attempts>' -e TARGET_ENDPOINT='<ip>:<port>' rintech/webtierbench:siege-webtier
