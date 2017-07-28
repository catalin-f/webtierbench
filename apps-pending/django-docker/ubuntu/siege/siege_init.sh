#!/bin/bash

su - tester -c "rm -rf /tmp/siege*                 \
    && cd django-workload/client                   \
    && LOG='/tmp/siege.log' ./run-siege" || exit 1

tail -f /dev/null
