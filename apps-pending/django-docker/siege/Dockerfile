# Use the latest ubuntu image as a base OS
FROM ubuntu:16.04

# Add the init script on the container to be run
ADD siege_init.sh /

# Make siege to start on boot time
CMD ./siege_init.sh
