#!/bin/bash

###############################################################################
# Environment data
###############################################################################


###############################################################################
# Commands
###############################################################################

docker run -tid -h siege --name siege_container --network django_network --ip 10.10.10.12 -e TARGET_ENDPOINT=10.10.10.11 rinftech/webtierbench:siege-webtier
