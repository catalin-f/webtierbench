#!/bin/bash

# This script is called when the cassandra image is built
# It receives the hostname as a parameter (cassandra)

HOSTNAME=$1

# Settings for 2-socket Broadwell-EP with 22 cores per socket,
# all services running on same machine

sed -i "s/listen_address: localhost/listen_address: $HOSTNAME/g" /etc/cassandra/cassandra.yaml
sed -i "s/seeds: \"127.0.0.1\"/seeds: \"$HOSTNAME\"/g" /etc/cassandra/cassandra.yaml
sed -i "s/rpc_address: localhost/rpc_address: $HOSTNAME/g" /etc/cassandra/cassandra.yaml
