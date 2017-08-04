#!/bin/bash

###############################################################################
# Environment data
WEBTIER_PATH=${WEBTIER_PATH}
WEBTIER_SIEGE_WORDPRESS=${WEBTIER_SIEGE_WORDPRESS}

###############################################################################

. ${WEBTIER_PATH}/apps/common_func.sh

###############################################################################
# Commands
###############################################################################

apt-get purge -y siege
if [ -n ${WEBTIER_SIEGE_WORDPRESS} ]; then
    rm /usr/local/bin/siege
fi
remove_settings
