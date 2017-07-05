#!/bin/bash

# Django workload setup
. utils.sh

check_root_privilege

# Add repositories
echo -e "\n\nAdd apt repositories ..."
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
echo -e "\n\nInstall packages ..."
apt-get install -y software-properties-common oracle-java8-installer    \
    cassandra memcached apt-transport-https ca-certificates docker-ce   \
    build-essential git libmemcached-dev python3-virtualenv python3-dev \
    zlib1g-dev siege curl

echo -e "\n\nDocker pull graphite image ..."
docker pull hopsoft/graphite-statsd

#Initialize docker container
echo -e "\n\nInitialize container ..."
docker run -d               \
    --name graphite         \
    --restart=always        \
    -p 80:80                \
    -p 2003-2004:2003-2004  \
    -p 2023-2024:2023-2024  \
    -p 8125:8125/udp        \
    -p 8126:8126            \
    hopsoft/graphite-statsd

# Disable services
echo -e "\n\nDisable services ..."
systemctl disable memcached.service
systemctl disable cassandra.service
systemctl disable docker.service

# Sets up a memcached server with 5 GB memory
# Check if system it's having 5 GB memory
echo -e "\n\nCheck system memory ..."
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

echo -e "\n\nClone django-workload repository ..."
git clone https://github.com/Instagram/django-workload

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

echo -e "\n\nCreate python virtual environment ..."
(
cd django-workload/django-workload || exit 4
python3 -m virtualenv -p python3 venv
source venv/bin/activate
pip install -r requirements.txt
deactivate
cp cluster_settings_template.py cluster_settings.py
)

echo -e "\n\nGenerate siege urls file ..."
(
cd django-workload/client || exit 5
./gen-urls-file
)

# Append client settings to /etc/sysctl.conf
echo -e "\nWrite sysctl settings ..."
cat >> /etc/sysctl.conf <<- EOF
	net.ipv4.tcp_tw_reuse=1
	net.ipv4.ip_local_port_range=1024 64000
	net.ipv4.tcp_fin_timeout=45
	net.core.netdev_max_backlog=10000
	net.ipv4.tcp_max_syn_backlog=12048
	net.core.somaxconn=1024
	net.netfilter.nf_conntrack_max=256000
EOF

echo -e "\n\nAdd nf_conntrack to modules ..."
echo "nf_conntrack" >> /etc/modules

echo -e "\n\nAdd limits settings ..."
cat >> /etc/security/limits.conf <<- EOF
	* soft nofile 1000000
	* hard nofile 1000000
EOF

# Add webtier username
echo -e "\n\nCreate webtier username ..."
useradd -m -s /bin/bash -c "WebTier Benchmark User" webtier
echo "failures = 1000000" > /home/webtier/.siegerc
chown webtier.webtier /home/webtier/.siegerc

echo
# Modifying limits.conf requires system reboot
read -rsn1 -p "Press any key to reboot"
reboot
