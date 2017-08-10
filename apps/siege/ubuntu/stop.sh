#!/bin/bash

###############################################################################
# Environment data
WEBTIER_SIEGE_WORKERS=${WEBTIER_SIEGE_WORKERS}
WEBTIER_SIEGE_RUNMODE=${WEBTIER_SIEGE_RUNMODE}
WEBTIER_SIEGE_WORDPRESS=${WEBTIER_SIEGE_WORDPRESS}
WEBTIER_PATH=${WEBTIER_PATH}

###############################################################################

. ${WEBTIER_PATH}/apps/common_func.sh

###############################################################################
# Commands
###############################################################################

if [ -z ${WEBTIER_SIEGE_WORDPRESS} ]; then
    killall run-siege
fi
killall siege
