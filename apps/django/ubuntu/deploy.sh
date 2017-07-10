#!/bin/bash

###############################################################################
# Environment data
###############################################################################
WEBTIER_HTTP_PROXY=${WEBTIER_HTTP_PROXY}
WEBTIER_DJANGO_REVISION=${WEBTIER_DJANGO_REVISION}
WEBTIER_DJANGO_WORKERS=${WEBTIER_DJANGO_WORKERS}


###############################################################################
# Commands
###############################################################################

# Install packages
http_proxy=${WEBTIER_HTTP_PROXY} https_proxy=${WEBTIER_HTTP_PROXY} apt-get install -y \
    python3-dev \
    python3-virtualenv


# Clone the GitHub project
su "$SUDO_USER" -c "HTTPS_PROXY=${WEBTIER_HTTP_PROXY} git clone https://github.com/Instagram/django-workload ;\
cd django-workload; git checkout ${WEBTIER_DJANGO_REVISION}"


# Setup django
su "$SUDO_USER" -c                                    \
"cd django-workload/django-workload                  ;\
python3 -m virtualenv -p python3 venv                ;\
source venv/bin/activate                             ;\
http_proxy=${WEBTIER_HTTP_PROXY} pip install -r requirements.txt   ;\
deactivate                                           ;\
cp cluster_settings_template.py cluster_settings.py"


# Set cores count to uwsgi.ini
su "$SUDO_USER" -c                             \
"cd django-workload/django-workload || exit 4; \
sed -i 's/processes = 4/processes = ${WEBTIER_DJANGO_WORKERS}/g' uwsgi.ini"