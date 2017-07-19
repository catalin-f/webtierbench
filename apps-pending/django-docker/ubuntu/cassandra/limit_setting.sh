#!/bin/bash

echo -e "\n\nAdd limits settings ..."
cat >> /etc/security/limits.conf <<- EOF
	* soft nofile 1000000
	* hard nofile 1000000
EOF
