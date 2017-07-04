#!/bin/bash

# Django workload removal
. utils.sh

check_root_privilege

# Remove repositories
add-apt-repository -r ppa:webupd8team/java
add-apt-repository -r "deb [arch=amd64]      \
    https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable"
apt-key del 0EBFCD88
apt-key del EEA14886

docker stop graphite
docker rm graphite
docker rmi hopsoft/graphite-statsd

# Remove packages and config files
apt-get remove -y software-properties-common oracle-java8-installer     \
    cassandra memcached apt-transport-https ca-certificates docker-ce   \
    build-essential git libmemcached-dev python3-virtualenv python3-dev \
    zlib1g-dev siege curl

apt-get -y autoremove

apt-get update

rm -rf django-workload
mv -f /etc/memcached.conf.old /etc/memcached.conf

# Remove sysctl settings
sed -e '/net.ipv4.tcp_tw_reuse=1/d'                 \
    -e '/net.ipv4.ip_local_port_range=1024 64000/d' \
    -e '/net.ipv4.tcp_fin_timeout=45/d'             \
    -e '/net.core.netdev_max_backlog=10000/d'       \
    -e '/net.ipv4.tcp_max_syn_backlog=12048/d'      \
    -e '/net.core.somaxconn=1024/d'                 \
    -e '/net.netfilter.nf_conntrack_max=256000/d'   \
    -i /etc/sysctl.conf

# Remove conntrack module
sed '/nf_conntrack/d' -i /etc/modules

# Remove limits settings
sed -e '/* soft nofile 1000000/d' \
    -e '/* hard nofile 1000000/d' \
    -i /etc/security/limits.conf

# Remove webtier username and its home directory
userdel -r webtier

# Modifying limits.conf requires system reboot
reboot
