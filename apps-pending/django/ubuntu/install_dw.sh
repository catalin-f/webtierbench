#!/bin/bash

# Django workload setup
. utils.sh

check_root_privilege

# This is true if we have proxy data supplied [default is false]
proxy_flag=false

[ "$1" ] && proxy_endpoint="$1"

# If we have a proxy, then we set the appropriate state
if [ "$#" -eq 1 ]  && check_proxy_parameter $proxy_endpoint; then
  echo "Proxy information was supplied correctly. Continuing with proxy settings..."
  set_general_proxy_configuration $proxy_endpoint
  proxy_flag=true

# If we don't have a proxy, we continue normally
else
  echo "Proxy information was supplied incorrectly (or not supplied at all). Continuing without proxy settings..."
fi

# Download neccessary packets
if [ "$proxy_flag" == "true" ]; then
  curl --proxy http://$proxy_endpoint https://www.apache.org/dist/cassandra/KEYS | apt-key add -
  curl --proxy http://$proxy_endpoint -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
else
  curl https://www.apache.org/dist/cassandra/KEYS | apt-key add -
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
fi

# Add repositories
echo -e "\n\nAdd apt repositories ..."

apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --keyserver-options http-proxy="http://$proxy_endpoint" --recv 0xC2518248EEA14886

echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" \
> /etc/apt/sources.list.d/webupd8team-ubuntu-java-xenial.list


echo "deb http://www.apache.org/dist/cassandra/debian 310x main" | \
     tee -a /etc/apt/sources.list.d/cassandra.sources.list

apt-key fingerprint 0EBFCD88
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable"

# We update our apt index
if [ "$proxy_flag" == "true" ]; then
  http_proxy=http://$proxy_endpoint apt-get update
else
  apt-get update
fi

# Install packages
echo -e "\n\nInstall packages ..."

if [ "$proxy_flag" == "true" ]; then
  http_proxy=http://$proxy_endpoint apt-get install -y software-properties-common     \
      cassandra memcached apt-transport-https ca-certificates docker-ce   \
      build-essential git libmemcached-dev python3-virtualenv python3-dev \
      zlib1g-dev siege curl

  http_proxy=http://$proxy_endpoint https_proxy=https://$proxy_endpoint apt-get install -y oracle-java8-installer

else
  apt-get install -y software-properties-common oracle-java8-installer    \
      cassandra memcached apt-transport-https ca-certificates docker-ce   \
      build-essential git libmemcached-dev python3-virtualenv python3-dev \
      zlib1g-dev siege curl

  apt-get install -y oracle-java8-installer
fi

#echo -e "\n\nDocker pull graphite image ..."
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
su "$SUDO_USER" -c "git clone https://github.com/Instagram/django-workload"

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
su "$SUDO_USER" -c                                    \
"cd django-workload/django-workload || exit 4         ;\

https_proxy=https://$proxy_endpoint http_proxy=http://$proxy_endpoint python3 -m virtualenv -p python3 venv  ;\

source venv/bin/activate                              ;\
if [ $proxy_flag == true ]; then
  https_proxy=https://$proxy_endpoint http_proxy=http://$proxy_endpoint pip install --proxy https://$proxy_endpoint -r requirements.txt   ;\
else
  pip install -r requirements.txt                     ;\
fi

deactivate                                            ;\
cp cluster_settings_template.py cluster_settings.py"
)

echo -e "\n\nGenerate siege urls file ..."
(
su "$SUDO_USER" -c                    \
"cd django-workload/client || exit 5; \
./gen-urls-file"
)

# Set cores count to uwsgi.ini
(
su "$SUDO_USER" -c                             \
"cd django-workload/django-workload || exit 4; \
sed -i 's/processes = 4/processes = $(grep -c processor /proc/cpuinfo)/g' uwsgi.ini"
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

# Create siegerc
echo -e "\n\nCreate siegerc ..."
su - "$SUDO_USER" -c "echo 'failures = 1000000' > .siegerc"

echo -e "\n\n"
# Modifying limits.conf requires system reboot
read -rsn1 -p "Press any key to reboot"
reboot
