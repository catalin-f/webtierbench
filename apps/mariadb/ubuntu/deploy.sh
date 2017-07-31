#!/bin/bash

###############################################################################
# Environment data
###############################################################################
WEBTIER_PATH=${WEBTIER_PATH}
WEBTIER_HTTP_PROXY=${WEBTIER_HTTP_PROXY}


###############################################################################
# Commands
###############################################################################
. ${WEBTIER_PATH}/apps/common_func.sh


#Install packages
http_proxy="${WEBTIER_HTTP_PROXY}" https_proxy="${WEBTIER_HTTP_PROXY}" apt-get install -y \
    mariadb-server
