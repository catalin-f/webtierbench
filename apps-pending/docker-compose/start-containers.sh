#!/bin/bash
  
# Django workload setup
. ../django/ubuntu/utils.sh

check_root_privilege

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

docker-compose -f webtierbench.yml up
