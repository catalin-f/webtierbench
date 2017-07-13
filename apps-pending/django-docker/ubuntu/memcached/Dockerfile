# Use the latest ubuntu image as a base OS
FROM ubuntu:16.04

# Set terminal to noninteractive
ENV DEBIAN_FRONTEND noninteractive

# Update our apt index and create scripts directory
RUN apt-get update && apt-get -y install memcached && mkdir scripts

# Copy necessary files to the container
COPY memcached_init.sh memcached.cfg /scripts/

# Set terminal to teletype
ENV DEBIAN_FRONTEND teletype

# Make memcached to start on boot time
CMD ./scripts/memcached_init.sh
