#!/bin/bash

################################### Description ########################################
#
# This script will start a docker container for each service necessary in the django workload
# It is created only for demonstration purposes, to see how we should power on a docker container.
# In a production environment, we'll use a tool that will manage our containers automatically.
#
########################################################################################

# This function will wait until the specified port on the specified machine is available
# Parameters: $1 = the IP; $2 = the port; $3 = the name of the service

wait_port() {
  while ! netcat -w 5 "$1" "$2"; do
    echo "Waiting for $3 ..."
    sleep 3
  done
}

docker network create --opt com.docker.network.bridge.name=django --attachable -d bridge --gateway 10.10.10.1 --subnet 10.10.10.0/24 --ip-range 10.10.10.8/29 django_network

echo "The network is up and running!"

# Start memcached container
docker run -tid -h memcached --name memcached_container --network django_network --ip 10.10.10.9 rinftech/webtierbench:memcached-webtier

echo "Memcached is up and running!"

# Start cassandra container
docker run -tid --privileged -h cassandra --name cassandra_container --privileged --network django_network --ip 10.10.10.10 rinftech/webtierbench:cassandra-webtier

wait_port 10.10.10.10 9042 cassandra

echo "Cassandra is up and running!"

# Start uwsgi container
docker run -tid -h uwsgi --name uwsgi_container --network django_network --ip 10.10.10.11 -e CASSANDRA_ENDPOINT=10.10.10.10 -e MEMCACHED_ENDPOINT=10.10.10.9 -e SIEGE_ENDPOINT=10.10.10.12 rinftech/webtierbench:uwsgi-webtier

wait_port 10.10.10.11 8000 uwsgi

echo "uWSGI is up and running!"

# Start siege container
docker run -ti -h siege --name siege_container --privileged --network django_network --ip 10.10.10.12 -e ATTEMPTS=10 -e TARGET_ENDPOINT=10.10.10.11 rinftech/webtierbench:siege-webtier
