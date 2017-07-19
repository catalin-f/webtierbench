#!/bin/bash

echo -e "\n\nAdd limits settings ..."
cat >> /etc/security/limits.conf <<- EOF
	* soft nofile 1000000
	* hard nofile 1000000
EOF

IP_ADDR=$(ifconfig eth0 | grep "inet addr" | cut -d ':' -f 2 | cut -d ' ' -f 1)

sed -i "s/listen_address: localhost/listen_address: $IP_ADDR/g" /etc/cassandra/cassandra.yaml
sed -i "s/seeds: \"127.0.0.1\"/seeds: \"$IP_ADDR\"/g" /etc/cassandra/cassandra.yaml
sed -i "s/rpc_address: localhost/rpc_address: $IP_ADDR/g" /etc/cassandra/cassandra.yaml
