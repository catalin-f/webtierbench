#!/bin/bash

rm -rf /tmp/siege*
chown -R tester:tester /tmp

su - tester -c "cd django-workload/client                                    \
                && sed -i 's/localhost/$TARGET_ENDPOINT/g' urls_template.txt \
                && ./gen-urls-file"                                          \

if [ -n "$RUNMODE" ]; then

	    for (( i=1; i<=$WORKERS; i++ ))
	    do
	        printf "\n### SIEGE RUN %d OUT OF %d ###\n\n" "$i" "$WORKERS"

          su - tester -c "cd django-workload/client                                    \
                          && LOG='/tmp/siege.log' ./run-siege --single"
	    done
else

      su - tester -c "cd django-workload/client                                    \
                     && LOG='/tmp/siege.log' ./run-siege"
fi
