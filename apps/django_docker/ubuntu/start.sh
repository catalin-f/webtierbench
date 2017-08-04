#!/bin/bash

###############################################################################
# Environment data
###############################################################################
CASSANDRA_IP=${CASSANDRA_IP}
MEMCACHED_IP=${MEMCACHED_IP}
GRAPHITE_IP=${GRAPHITE_IP}

###############################################################################
# Commands
###############################################################################

docker run -tid -h uwsgi --name uwsgi_container --network django_network --ip 10.10.10.11 -e GRAPHITE_ENDPOINT=$GRAPHITE_IP -e CASSANDRA_ENDPOINT=$CASSANDRA_IP -e MEMCACHED_ENDPOINT=$MEMCACHED_IP rinftech/webtierbench:uwsgi-webtier
