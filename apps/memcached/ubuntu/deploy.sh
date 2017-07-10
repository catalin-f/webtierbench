#!/bin/bash

###############################################################################
# Environment data
###############################################################################
WEBTIER_HTTP_PROXY=${WEBTIER_HTTP_PROXY}


###############################################################################
# Commands
###############################################################################

# Install packages
http_proxy=${WEBTIER_HTTP_PROXY} https_proxy=${WEBTIER_HTTP_PROXY}  apt-get install -y \
    libmemcached-dev \
    memcached


# Disable Memcached service
systemctl disable memcached.service


# Backup old memcached config file
if [ -f /etc/memcached.conf ]; then
    mv /etc/memcached.conf /etc/memcached.conf.old
fi


# Write a new memcached config
cat > /etc/memcached.conf <<- EOF
	# Daemon mode
	-d
	logfile /var/log/memcached.log
	-m "5120"
	-p "11811"
	-u "memcache"
	-l "0.0.0.0"
EOF