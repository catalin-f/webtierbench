# Use the latest ubuntu image as a base OS
# Update apt index
# Create scripts directory
# Install siege dependencies
# Clone the django repository
# Set the working directory
# Switch the repository to our checked revision and generate siege urls
# Update siegerc with the failures limit
# Add the init script on the container to be run
# Make siege to start on boot time

FROM ubuntu:16.04

RUN apt-get update                                                \
    && mkdir /scripts                                             \
    && apt-get -y install git siege python3                       \
    && git clone https://github.com/Instagram/django-workload.git

WORKDIR django-workload/

RUN git checkout b18dace0491051ba85b5fed908db8a92adb2f2ae \
    && echo 'failures = 1000000' > .siegerc

COPY siege_init.sh /scripts/

CMD cd /scripts        \
    && ./siege_init.sh
