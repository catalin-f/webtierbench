#!/bin/bash

###############################################################################
# Environment data
###############################################################################
WEBTIER_SIEGE_WORKERS=${WEBTIER_SIEGE_WORKERS}
WEBTIER_SIEGE_RUNMODE=${WEBTIER_SIEGE_RUNMODE}

###############################################################################
# Commands
###############################################################################
docker run -ti -h siege --name siege_container --network django_network --ip 10.10.10.12 -e TARGET_ENDPOINT=10.10.10.11 rinftech/webtierbench:siege-webtier
