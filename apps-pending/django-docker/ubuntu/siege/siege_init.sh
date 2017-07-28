#!/bin/bash

rm -rf /tmp/siege*
chown -R tester:tester /tmp

su - tester -c "cd django-workload/client \
    && LOG='/tmp/siege.log' ./run-siege"  \
    || exit 1

tail -f /dev/null
