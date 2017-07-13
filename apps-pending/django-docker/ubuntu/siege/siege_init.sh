#!/bin/bash

# This script will configure and start the siege service inside a docker
# container based on Ubuntu 16.04

apt-get update

apt-get -y install git siege python3

git clone https://github.com/Instagram/django-workload.git

cd django-workload/client

./gen-urls-file

echo 'failures = 1000000' > .siegerc

./run-siege.sh && tail -F /dev/null
