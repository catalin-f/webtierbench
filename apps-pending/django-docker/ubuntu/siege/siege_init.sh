#!/bin/bash

# This script will configure and start the siege service inside a docker
# container based on Ubuntu 16.04

# This is the revision that we chose for the django workload repository
WEBTIER_DJANGO_REVISION=b18dace0491051ba85b5fed908db8a92adb2f2ae

# Update our apt index
apt-get update

# Install siege dependencies
apt-get -y install git siege python3

# Clone the django repository
git clone https://github.com/Instagram/django-workload.git

# Switch the repository to our checked revision
cd django-workload/client; git checkout ${WEBTIER_DJANGO_REVISION}

# Generate urls file
./gen-urls-file

# Update siegerc with the failures limit
echo 'failures = 1000000' > .siegerc

# Start siege and keep the process running
./run-siege.sh && tail -F /dev/null
