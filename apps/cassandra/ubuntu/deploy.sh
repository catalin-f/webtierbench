#!/bin/bash

###############################################################################
# Environment data
###############################################################################
WEBTIER_HTTP_PROXY=${WEBTIER_HTTP_PROXY}


###############################################################################
# Commands
###############################################################################

# Add keys
curl --proxy ${WEBTIER_HTTP_PROXY} https://www.apache.org/dist/cassandra/KEYS | apt-key add -


# Add repo
http_proxy=${WEBTIER_HTTP_PROXY} https_proxy=${WEBTIER_HTTP_PROXY} add-apt-repository ppa:webupd8team/java
echo "deb http://www.apache.org/dist/cassandra/debian 310x main" | \
     tee -a /etc/apt/sources.list.d/cassandra.sources.list
http_proxy=${WEBTIER_HTTP_PROXY} https_proxy=${WEBTIER_HTTP_PROXY} apt-get update


# Install packages
http_proxy=${WEBTIER_HTTP_PROXY} https_proxy=${WEBTIER_HTTP_PROXY}  apt-get install -y \
    cassandra \
    oracle-java8-installer \
    software-properties-common


# Disable Cassandra service
systemctl disable cassandra.service
