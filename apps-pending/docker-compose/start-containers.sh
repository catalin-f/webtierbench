#!/bin/bash
  
# Django workload setup
. ../django/ubuntu/utils.sh

check_root_privilege

if ! [ -f /etc/apt/sources.list.d/docker.list ]; then
    echo "Install docker latest version for Ubuntu 16.04 ..."
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
    echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable" \
    > /etc/apt/sources.list.d/docker.list

    apt-get update
    apt-get install -y docker
fi

if ! which docker-compose > /dev/null; then
    echo "Docker-compose not found! Installing it ..."
    
    apt-get update
    apt-get install -y docker-compose
fi

# Check for proxy
if [ "$#" -gt "0" ]; then
    case "$1" in
        -p | --proxy)
            [ -z "$2" ] && usage "-p | --proxy <proxy_ip:proxy_port>"

            echo -e "\n\nSet proxy ..."

            proxy_endpoint="$2"

            # Set docker proxy
            ! [ -d /etc/systemd/system/docker.service.d ] \
                && mkdir -p /etc/systemd/system/docker.service.d

            if ! [ -f /etc/systemd/system/docker.service.d/http-proxy.conf ]; then
                echo "[Service]" > /etc/systemd/system/docker.service.d/http-proxy.conf
                echo "Environment='HTTP_PROXY=http://$proxy_endpoint'" \
                    >> /etc/systemd/system/docker.service.d/http-proxy.conf

                # Reload Docker new settings
                systemctl daemon-reload
                systemctl restart docker.service
            fi

            echo "Docker proxy set!"
            ;;

        *)
            usage "-p | --proxy <proxy_ip:proxy_port>"
    esac
fi

# Set host's cpu for performance
echo "Set CPU for performance ..."
. ../django/ubuntu/utils.sh
set_cpu_performance

# Activate sysctl settings on host.
# We keep all sysctl settings on host because,
# we can't activate all of them in container,
# even if container is running in privileged mode.

echo "Activate sysctl settings ..."
sysctl -p ../django-docker/ubuntu/siege/set_sysctl.conf

# Ensure docker service is started
systemctl start docker.service

docker-compose -f webtierbench.yml up
