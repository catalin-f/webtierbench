#!/bin/bash

rm -rf /tmp/siege*
chown -R tester:tester /tmp

su - tester -c "cd django-workload/client                                    \
                && sed -i 's/localhost/$TARGET_ENDPOINT/g' urls_template.txt \
                && ./gen-urls-file                                           \
                && LOG='/tmp/siege.log' ./run-siege"
