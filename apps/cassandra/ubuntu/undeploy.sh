#!/bin/bash

###############################################################################
# Environment data
###############################################################################


###############################################################################
# Commands
###############################################################################

rm -f /etc/apt/sources.list.d/webupd8team-ubuntu-java-xenial.list \
/etc/apt/sources.list.d/cassandra.sources.list

apt-get purge -y oracle-java8-installer cassandra