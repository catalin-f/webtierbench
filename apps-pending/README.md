This directory contains all applications that are going to be ported to WebTierBench backend.

To run django-workload natively, navigate to django/ubuntu directory and consult README.md file.
- all services run directly on the host, except graphite which runs in docker container

To run django-workload in docker containers, navigate to docker-compose directory and consult README.TXT file.
- all services run in containers on same host
