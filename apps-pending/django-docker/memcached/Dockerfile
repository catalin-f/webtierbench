# Use the latest ubuntu image as a base OS
FROM ubuntu:latest

# Update our apt index
RUN apt-get update

# Install memcached
RUN apt-get -y install memcached

# Copy the memcached config to the root directory on the container
ADD memcached.cfg /

# Copy the memcached init script to the container
ADD memcached_init.sh /

# Make memcached to start on boot time
CMD ./memcached_init.sh
