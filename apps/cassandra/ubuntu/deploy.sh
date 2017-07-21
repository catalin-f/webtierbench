#!/bin/bash

###############################################################################
# Environment data
###############################################################################
WEBTIER_HTTP_PROXY=${WEBTIER_HTTP_PROXY}


###############################################################################
# Commands
###############################################################################
CODENAME=`lsb_release -c -s`

# Add keys
curl --proxy "${WEBTIER_HTTP_PROXY}" -fsSL https://www.apache.org/dist/cassandra/KEYS | apt-key add -


# Add repo
echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu ${CODENAME} main" > /etc/apt/sources.list.d/webupd8team-ubuntu-java-${CODENAME}.list
echo "deb http://www.apache.org/dist/cassandra/debian 310x main" > /etc/apt/sources.list.d/cassandra.sources.list
http_proxy="${WEBTIER_HTTP_PROXY}" https_proxy="${WEBTIER_HTTP_PROXY}" apt-get update


# Install packages
http_proxy="${WEBTIER_HTTP_PROXY}" https_proxy="${WEBTIER_HTTP_PROXY}" apt-get install -y \
    oracle-java8-installer \
    cassandra \
    software-properties-common


# Disable Cassandra service
systemctl disable cassandra.service
