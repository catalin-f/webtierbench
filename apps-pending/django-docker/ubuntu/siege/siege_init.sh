#!/bin/bash

################################### Description ########################################
#
# This script will be called when the siege container is run (powered on / executed).
# When we run the siege container, we need to pass the number of runs that siege needs to perform
# We will do this passing using environment variables that we set when the docker run command is run
# and we read them in this script.
# For example, consider following command:
#
#   docker run -e ATTEMPTS=10 -e TARGET_ENDPOINT='192.168.0.1:5050' siege-webtier
#
# In this script, we will have access to the ATTEMPTS variable.
#
########################################################################################

#### This script is currently under development ####

# Set the working directory
cd /django-workload/client

# Update the target endpoint
sed -i "s/localhost:8000/$TARGET_ENDPOINT/g" urls_template.txt

# Generate the urls with the updated endpoint
./gen-urls-file

# Run siege $ATTEMPTS times
for (( i=1; i<=$ATTEMPTS; i++ ))
	do
	   ./run-siege.sh
done

# Keep the siege process running
tail -F /dev/null
