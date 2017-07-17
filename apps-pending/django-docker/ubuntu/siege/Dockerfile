# Use the latest ubuntu image as a base OS
FROM ubuntu:16.04

# Update apt index
RUN apt-get update

# Create scripts directory
RUN mkdir /scripts

# Install siege dependencies
RUN apt-get -y install git siege python3

# Clone the django repository
RUN git clone https://github.com/Instagram/django-workload.git

# Set the working directory
WORKDIR django-workload/

# Switch the repository to our checked revision and generate siege urls
RUN git checkout b18dace0491051ba85b5fed908db8a92adb2f2ae

# Update siegerc with the failures limit
RUN echo 'failures = 1000000' > .siegerc

# Add the init script on the container to be run
COPY siege_init.sh /scripts/

# Make siege to start on boot time
CMD ./siege_init.sh
