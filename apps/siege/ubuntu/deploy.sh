#!/bin/bash

###############################################################################
# Environment data
###############################################################################
WEBTIER_HTTP_PROXY=${WEBTIER_HTTP_PROXY}
WEBTIER_DJANGO_REVISION=${WEBTIER_DJANGO_REVISION}


###############################################################################
# Commands
###############################################################################


if [ "${WEBTIER_OSS_PERFROMANCE_REV}" ]; then
    su "$SUDO_USER" -c "HTTPS_PROXY=${WEBTIER_HTTP_PROXY} wget http://download.joedog.org/siege/siege-2.78.tar.gz"
    su "$SUDO_USER" tar xzf siege-2.78.tar.gz
    cd siege-2.78/
    ./configure
    make
    make install
else
# Install packages
    http_proxy="${WEBTIER_HTTP_PROXY}" https_proxy=$"{WEBTIER_HTTP_PROXY}" apt-get install -y \
        siege

# Clone the GitHub project
    su "$SUDO_USER" -c "HTTPS_PROXY=${WEBTIER_HTTP_PROXY} git clone https://github.com/Instagram/django-workload ;\
    cd django-workload; git checkout ${WEBTIER_DJANGO_REVISION}"


# Generate siege urls file
    su "$SUDO_USER" -c "cd django-workload/client; ./gen-urls-file"

fi

# Create siegerc
    su - "$SUDO_USER" -c "echo 'failures = 1000000' > ~/.siegerc"


# Append client settings to /etc/sysctl.conf
cat >> /etc/sysctl.conf <<- EOF
   net.ipv4.tcp_tw_reuse=1
   net.ipv4.ip_local_port_range=1024 64000
   net.ipv4.tcp_fin_timeout=45
   net.core.netdev_max_backlog=10000
   net.ipv4.tcp_max_syn_backlog=12048
   net.core.somaxconn=1024
   net.netfilter.nf_conntrack_max=256000
EOF
sysctl -f

