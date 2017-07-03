#!/bin/bash

# Django workload setup
if [ "$(id -u)" -ne "0" ]; then
    echo "You have to be root!"
    exit 1
fi

# Add repositories
add-apt-repository ppa:webupd8team/java
echo "deb http://www.apache.org/dist/cassandra/debian 310x main" | \
     tee -a /etc/apt/sources.list.d/cassandra.sources.list
curl https://www.apache.org/dist/cassandra/KEYS | apt-key add -
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
apt-key fingerprint 0EBFCD88
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable"
apt-get update

# Install packages
apt-get install -y software-properties-common oracle-java8-installer    \
    cassandra memcached apt-transport-https ca-certificates docker-ce   \
    build-essential git libmemcached-dev python3-virtualenv python3-dev \
    zlib1g-dev siege curl

# Stop and disable services
systemctl stop memcached.service
systemctl disable memcached.service
systemctl stop cassandra.service
systemctl disable cassandra.service
systemctl stop docker.service
systemctl disable docker.service

# Sets up a memcached server with 5 GB memory
# Check if system it's having 5 GB memory
mem_total_MB=$(free -m | grep Mem | awk '{print $2}')
mem_av_MB=$(free -m | grep Mem | awk '{print $NF}')

if [ "$mem_total_MB" -ge "5120" ]; then
    if [ "$mem_av_MB" -ge "2048" ]; then
        echo "Found enough memory on the system! [OK]"
    else
        echo "Not enough available memory on the system! [FAIL]"
        exit 2
    fi 
else
    echo "Not enough memory in the system! [FAIL]"
    exit 3
fi

git clone https://github.com/Instagram/django-workload

# Config memcached
# Backup old system memcached config file
if [ -f /etc/memcached.conf ]; then
    mv /etc/memcached.conf /etc/memcached.conf.old
    echo "Backup /etc/memcached.conf to /etc/memcached.conf.old"
fi

. memcached.cfg

cat > /etc/memcached.conf <<- EOF
	# Daemon mode
	-d
	logfile /var/log/memcached.log
	-m "$MEMORY"
	-p "$PORT"
	-u "$USER"
	-l "$LISTEN"
EOF

(
cd django-workload/django-workload || exit 4
python3 -m virtualenv -p python3 venv
source venv/bin/activate
pip install -r requirements.txt
deactivate
cp cluster_settings_template.py cluster_settings.py
)

(
cd django-workload/client || exit 5
./gen-urls-file
)

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

echo "nf_conntrack" >> /etc/modules

cat >> /etc/security/limits.conf <<- EOF
	* soft nofile 1000000
	* hard nofile 1000000
EOF

# Modifying limits.conf requires system reboot
reboot
