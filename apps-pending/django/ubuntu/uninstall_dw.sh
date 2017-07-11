#!/bin/bash

# Django workload removal
. utils.sh

check_root_privilege

# Remove repositories
echo -e "\n\nRemove apt repositories ..."
add-apt-repository -r ppa:webupd8team/java
add-apt-repository -r "deb [arch=amd64]      \
    https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable"
rm -f /etc/apt/sources.list.d/cassandra.sources.list
apt-key del 0EBFCD88
apt-key del EEA14886

# Remove docker image and container
echo -e "\n\nRemove Docker image and container ..."
docker stop graphite
docker rm graphite
docker rmi hopsoft/graphite-statsd

rm -rf /etc/systemd/system/docker.service.d

# Purge packages
echo -e "\n\nPurge packages ..."
apt-get purge -y oracle-java8-installer \
    memcached cassandra docker-ce       \
    python3-virtualenv python3-dev      \
    zlib1g-dev siege

# Do not remove ntp
apt-mark manual ntp

apt-get -y autoremove

echo -e "\n\nUpdate repositories ..."
apt-get update

echo -e "\n\nRemove django-workload cloned repository ..."
rm -rf django-workload

echo -e "\n\nRemove memcached backup config file ..."
rm -f /etc/memcached.conf.old

# Remove sysctl settings
echo -e "\n\nRemove sysctl settings ..."
sed -e '/net.ipv4.tcp_tw_reuse=1/d'                 \
    -e '/net.ipv4.ip_local_port_range=1024 64000/d' \
    -e '/net.ipv4.tcp_fin_timeout=45/d'             \
    -e '/net.core.netdev_max_backlog=10000/d'       \
    -e '/net.ipv4.tcp_max_syn_backlog=12048/d'      \
    -e '/net.core.somaxconn=1024/d'                 \
    -e '/net.netfilter.nf_conntrack_max=256000/d'   \
    -i /etc/sysctl.conf

# Remove nf_conntrack module
echo -e "\n\nRemove nf_conntrack module ..."
sed '/nf_conntrack/d' -i /etc/modules

# Remove limits settings
echo -e "\n\nRemove limits settings ..."
sed -e '/* soft nofile 1000000/d' \
    -e '/* hard nofile 1000000/d' \
    -i /etc/security/limits.conf

echo -e "\n\n"
# Modifying limits.conf requires system reboot
read -rsn1 -p "Press any key to reboot"
reboot
