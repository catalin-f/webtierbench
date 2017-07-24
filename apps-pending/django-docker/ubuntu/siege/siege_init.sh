#!/bin/bash

# This script is called each time the siege container is run

cd /django-workload/client || exit 1

sed -i "s/localhost/$TARGET_ENDPOINT/g" urls_template.txt

./gen-urls-file

./run-siege

tail -f /dev/null
