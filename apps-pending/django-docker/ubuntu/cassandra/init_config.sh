#!/bin/bash

# This script is called when the cassandra image is built
# It receives the hostname as a parameter (cassandra)

echo -e "\n\nAdd limits settings ..."
cat >> /etc/security/limits.conf <<- EOF
	* soft nofile 1000000
	* hard nofile 1000000
EOF

HOSTNAME=$1

sed -i "s/listen_address: localhost/listen_address: $HOSTNAME/g" /etc/cassandra/cassandra.yaml
sed -i "s/seeds: \"127.0.0.1\"/seeds: \"$HOSTNAME\"/g" /etc/cassandra/cassandra.yaml
sed -i "s/rpc_address: localhost/rpc_address: $HOSTNAME/g" /etc/cassandra/cassandra.yaml
