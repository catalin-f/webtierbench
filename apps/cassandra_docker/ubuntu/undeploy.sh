#!/bin/bash

###############################################################################
# Environment data
###############################################################################


###############################################################################
# Commands
###############################################################################

docker stop cassandra_container
docker rmi rinftech/webtierbench:cassandra-webtier
