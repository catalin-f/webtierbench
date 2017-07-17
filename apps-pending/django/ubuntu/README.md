# Django Workload

This directory contains all the necessary scripts that you can use to interact with Django Workload

## Install

sudo ./install_dw.sh [-p | --proxy <proxy_ip:proxy_port>]

## Uninstall

sudo ./uninstall_dw.sh

## Run Benchmark

sudo ./start-benchmark.sh <number_of_attempts>

For example: **sudo ./start-benchmark.sh 1**

## Stop Benchmark

sudo ./stop-benchmark.sh

## Additional information

The files utils.sh and memcached.cfg are used internally by our scripts so they shouldn't be used by the user.
