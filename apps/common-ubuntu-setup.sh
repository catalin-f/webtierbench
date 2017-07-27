#!/bin/bash
. ./apps/common_func.sh

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

if [ "${WEBTIER_HTTP_PROXY}" ]; then
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --keyserver-options http-proxy="http://${WEBTIER_HTTP_PROXY}" --recv 0xC2518248EEA14886
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --keyserver-options http-proxy="http://${WEBTIER_HTTP_PROXY}" --recv-keys 0x5a16e7281be7a449
else
	apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0xC2518248EEA14886
	apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 0x5a16e7281be7a449
fi
debug ">>>> apt-key adv --keyserver hkp://keyserver.ubuntu.com:80  \n"

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
    zlib1g-dev\
    util-linux\
    software-properties-common \
    python-software-properties \
    python-pip\
    python3-virtualenv\
    python3-dev

http_proxy="${WEBTIER_HTTP_PROXY}" https_proxy="${WEBTIER_HTTP_PROXY}" add-apt-repository -y ppa:webupd8team/java

debug  ">>>> other requirements\n"

# Prepare the Python environment
http_proxy="${WEBTIER_HTTP_PROXY}" https_proxy="${WEBTIER_HTTP_PROXY}" pip install --upgrade pip
http_proxy="${WEBTIER_HTTP_PROXY}" https_proxy="${WEBTIER_HTTP_PROXY}" pip --no-cache-dir install -r requirements.txt
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