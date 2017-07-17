# Use the latest ubuntu image as a base OS
FROM ubuntu:16.04

# Update our apt index and install necessary packets
RUN apt-get update && apt-get install -y git python3-virtualenv python3-dev python-pip libmemcached-dev zlib1g-dev

# Create the scripts folder
RUN mkdir /scripts

# Copy the init script to the scripts folder on the container
COPY uwsgi_init.sh /scripts

# Clone django workload repository
RUN git clone https://github.com/Instagram/django-workload

# Set work directory
WORKDIR django-workload/django-workload

# Switch the repository to our checked revisions
RUN git checkout b18dace0491051ba85b5fed908db8a92adb2f2ae

# Create the virtual environment and activate it
RUN python3 -m virtualenv -p python3 venv

# Activate the virtual environment
RUN /bin/bash -c "source venv/bin/activate"

# Install necessary requirements
RUN pip install -r requirements.txt

# Update the cluster settings file
RUN cp cluster_settings_template.py cluster_settings.py

# Update the work directory
WORKDIR /scripts

# Start uWSGI
CMD ./uwsgi_init.sh
