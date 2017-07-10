#!/bin/bash

###############################################################################
# Environment data
###############################################################################
WEBTIER_HTTP_PROXY=${WEBTIER_HTTP_PROXY}


###############################################################################
# Commands
###############################################################################

# Update the local package content cache
http_proxy=${WEBTIER_HTTP_PROXY} https_proxy=${WEBTIER_HTTP_PROXY} apt-get update


# Pre-requirements
http_proxy=${WEBTIER_HTTP_PROXY} https_proxy=${WEBTIER_HTTP_PROXY} apt-get install -y \
    curl


# Prepare for Docker
curl --proxy ${WEBTIER_HTTP_PROXY} -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
http_proxy=${WEBTIER_HTTP_PROXY} https_proxy=${WEBTIER_HTTP_PROXY} apt-key fingerprint 0EBFCD88
http_proxy=${WEBTIER_HTTP_PROXY} https_proxy=${WEBTIER_HTTP_PROXY} add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable"
http_proxy=${WEBTIER_HTTP_PROXY} https_proxy=${WEBTIER_HTTP_PROXY} apt-get update


# Other requirements
http_proxy=${WEBTIER_HTTP_PROXY} https_proxy=${WEBTIER_HTTP_PROXY} apt-get install -y \
    apt-transport-https \
    build-essential \
    ca-certificates \
    docker-ce \
    git \
    zlib1g-dev


# Prepare the Python environment
http_proxy=${WEBTIER_HTTP_PROXY} pip install -r requirements.txt


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