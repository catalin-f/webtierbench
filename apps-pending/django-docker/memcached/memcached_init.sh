#!/bin/bash
# This script will configure and start the memcached service inside a docker
# container based on Ubuntu 16.04

# Config memcached
# Backup old memcached config file
if [ -f /etc/memcached.conf ]; then
    mv /etc/memcached.conf /etc/memcached.conf.old
    echo -e "\n\nBackup /etc/memcached.conf to /etc/memcached.conf.old"
fi

. memcached.cfg

echo -e "\n\nWrite memcached config file ..."
cat > /etc/memcached.conf <<- EOF
	# Daemon mode
	-d
	logfile /var/log/memcached.log
	-m "$MEMORY"
	-p "$PORT"
	-u "$USER"
	-l "$LISTEN"
EOF

# Run the memcached service
service memcached start && tail -F /dev/null
