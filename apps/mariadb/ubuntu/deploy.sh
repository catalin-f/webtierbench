#!/bin/bash

. ../../common_func.sh

###############################################################################
# Environment data
###############################################################################
WEBTIER_HTTP_PROXY=${WEBTIER_HTTP_PROXY}


###############################################################################
# Commands
###############################################################################

#Install packages
http_proxy="${WEBTIER_HTTP_PROXY}" https_proxy="${WEBTIER_HTTP_PROXY}" apt-get install -y \
    mariadb-server
