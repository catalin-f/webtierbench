#!/bin/bash

. ../../common_func.sh

###############################################################################
# Environment data
###############################################################################


###############################################################################
# Commands
###############################################################################
check_root_privilege
apt-get purge -y  nginx hhvm