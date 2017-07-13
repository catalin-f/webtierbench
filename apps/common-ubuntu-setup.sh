#!/bin/bash
. ./common_func.sh

###############################################################################
# Environment data
###############################################################################
WEBTIER_HTTP_PROXY=${WEBTIER_HTTP_PROXY}
echo "WEBTIER_HTTP_PROXY=${WEBTIER_HTTP_PROXY}"

###############################################################################
# Commands
###############################################################################
CODENAME=`lsb_release -c -s`

# Update the local package content cache
http_proxy="${WEBTIER_HTTP_PROXY}" https_proxy="${WEBTIER_HTTP_PROXY}" apt-get update
debug ">>>> apt-get update\n"

# Pre-requirements
http_proxy="${WEBTIER_HTTP_PROXY}" https_proxy="${WEBTIER_HTTP_PROXY}" apt-get install -y \
    curl
debug ">>>> apt-get install curl\n"

# Prepare for Docker
curl --proxy "${WEBTIER_HTTP_PROXY}" -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
http_proxy=${WEBTIER_HTTP_PROXY} https_proxy=${WEBTIER_HTTP_PROXY} apt-key fingerprint 0EBFCD88
echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu ${CODENAME} stable" > /etc/apt/sources.list.d/docker-ubuntu-${CODENAME}.list
http_proxy="${WEBTIER_HTTP_PROXY}" https_proxy="${WEBTIER_HTTP_PROXY}" apt-get update
debug  ">>>> Docker prepare\n"

# Other requirements
http_proxy="${WEBTIER_HTTP_PROXY}" https_proxy="${WEBTIER_HTTP_PROXY}" apt-get install -y \
    apt-transport-https \
    build-essential \
    ca-certificates \
    docker-ce \
    git \
    zlib1g-dev
debug  ">>>> other requirements\n"

# Prepare the Python environment
http_proxy="${WEBTIER_HTTP_PROXY}" https_proxy="${WEBTIER_HTTP_PROXY}" pip install -r requirements.txt
debug  "pip install\n"

# Disable Docker service
systemctl disable docker.service


# Add nf_conntrack to modules
echo "nf_conntrack" >> /etc/modules


# Add limits settings
cat >> /etc/security/limits.conf <<- EOF
	* soft nofile 1000000
	* hard nofile 1000000
	root soft nofile 1000000
	root hard nofile 1000000
EOF

# If reboot is required
touch /tmp/.host.reboot.required