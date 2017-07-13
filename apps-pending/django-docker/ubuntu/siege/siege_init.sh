#!/bin/bash

# This script will configure and start the siege service inside a docker
# container based on Ubuntu 16.04

# Start siege and keep the process running
cd django-workload/client && ./run-siege.sh && tail -F /dev/null
