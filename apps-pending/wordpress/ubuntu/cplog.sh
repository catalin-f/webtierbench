#!/bin/bash

log_file=$(find /tmp/logs -type f -name "siege*")
cp $log_file $HOME/siege.log
