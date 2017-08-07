# Django Workload

This directory contains all the necessary scripts that you can use to interact with Django Workload

## Install

**sudo ./install_dw.sh [-p | --proxy <proxy_ip:proxy_port>]**

## Uninstall

sudo ./uninstall_dw.sh

## Run Benchmark

sudo ./start-benchmark.sh

For example: **sudo ./start-benchmark.sh**

## Stop Benchmark

**sudo ./stop-benchmark.sh**

## Additional information

The files utils.sh and memcached.cfg are used internally by our scripts so they shouldn't be used by the user.

The script **install_dw.sh** installs django workload natively. It clones the django workload (from [this](https://github.com/Instagram/django-workload)
repository) and uses the state of the repository marked by the following commit id: **2600e3e784cb912fe7b9dbe4ebc8b26d43e1bacb**

NOTICE:
Before running other test it's recommended to stop services involved in benchmarking, using command:
sudo ./stop-benchmark.sh

This will stop cassandra, memcached, graphite, uwsgi, siege.
