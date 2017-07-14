# Use the latest ubuntu image as a base OS
FROM ubuntu:16.04

# This is the commit of the stable revision of django workload
ENV DJANGO_REVISION b18dace0491051ba85b5fed908db8a92adb2f2ae

# Update apt index
RUN apt-get update

# Install siege dependencies
RUN apt-get -y install git siege python3

# Clone the django repository
RUN git clone https://github.com/Instagram/django-workload.git

# Switch the repository to our checked revision and generate siege urls
RUN cd django-workload/client && git checkout $DJANGO_REVISION && ./gen-urls-file

# Update siegerc with the failures limit
RUN echo 'failures = 1000000' > .siegerc

# Add the init script on the container to be run
COPY siege_init.sh /

# Make siege to start on boot time
CMD ./siege_init.sh
